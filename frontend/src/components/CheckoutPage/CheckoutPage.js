import React, { useContext, useState } from "react";
import {
  Stepper,
  Step,
  StepLabel,
  Button,
  Typography,
  CircularProgress,
  Dialog,
  DialogContent,
  DialogActions,
  makeStyles,
} from "@material-ui/core";
import { Formik, Form } from "formik";
import { FaCheckCircle } from 'react-icons/fa';

import AddressForm from "./Forms/AddressForm";
import PaymentForm from "./Forms/PaymentForm";
import ReviewOrder from "./ReviewOrder";
import CheckoutSuccess from "./CheckoutSuccess";

import api from "../../services/api";
import toastError from "../../errors/toastError";
import { toast } from "react-toastify";
import { AuthContext } from "../../context/Auth/AuthContext";


import validationSchema from "./FormModel/validationSchema";
import checkoutFormModel from "./FormModel/checkoutFormModel";
import formInitialValues from "./FormModel/formInitialValues";

const useStyles = makeStyles((theme) => ({
  root: {
    width: '100%',
    padding: theme.spacing(3),
  },
  header: {
    textAlign: 'center',
    marginBottom: theme.spacing(4),
  },
  headerTitle: {
    color: theme.palette.primary.main,
    fontWeight: 600,
    marginBottom: theme.spacing(2),
  },
  stepper: {
    marginBottom: theme.spacing(4),
  },
  buttons: {
    display: 'flex',
    justifyContent: 'space-between',
    marginTop: theme.spacing(3),
  },
  button: {
    marginRight: theme.spacing(1),
  },
  wrapper: {
    position: 'relative',
  },
  buttonProgress: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    marginTop: -12,
    marginLeft: -12,
  },
  successDialog: {
    textAlign: 'center',
    padding: theme.spacing(3),
  },
  successIcon: {
    fontSize: 64,
    color: '#4CAF50',
    marginBottom: theme.spacing(2),
  },
}));

export default function CheckoutPage(props) {
  const steps = ["Data", "Pembayaran", "Konfirmasi"];
  const { formId, formField } = checkoutFormModel;
  const classes = useStyles();
  const [activeStep, setActiveStep] = useState(1);
  const [datePayment, setDatePayment] = useState(null);
  const [showSuccess, setShowSuccess] = useState(false);
  const currentValidationSchema = validationSchema[activeStep];
  const isLastStep = activeStep === steps.length - 1;
  const { user } = useContext(AuthContext);
  const { plan, onSubmit } = props;

  function _renderStepContent(step, setFieldValue, setActiveStep, values) {
    switch (step) {
      case 0:
        return <AddressForm formField={formField} values={values} setFieldValue={setFieldValue} />;
      case 1:
        return <PaymentForm 
          formField={formField} 
          setFieldValue={setFieldValue} 
          setActiveStep={setActiveStep} 
          activeStep={step} 
          values={values}
        />;
      case 2:
        return <ReviewOrder plan={plan} />;
      default:
        return <div>Not Found</div>;
    }
  }

  async function _submitForm(values, actions) {
    try {
      // Buat transaksi di backend
      const { data } = await api.post("/subscription/payment", {
        planId: plan.id,
        price: Number(plan.price),
        users: Number(plan.users),
        connections: Number(plan.connections),
        queues: Number(plan.queues),
        email: values.email,
        name: values.name,
        phone: values.phone
      });
      
      if (typeof window.snap === 'undefined') {
        toast.error("Error: Midtrans Snap tidak tersedia");
        return;
      }

      window.snap.pay(data.token, {
        onSuccess: function(result) {
          setShowSuccess(true);
          toast.success("Pembayaran berhasil!");
        },
        onPending: function(result) {
          toast.info("Pembayaran belum selesai");
        },
        onError: function(result) {
          toast.error("Pembayaran gagal");
          window.location.href = "/subscription/error";
        },
        onClose: function() {
          toast.info("Jendela pembayaran ditutup");
        }
      });

      actions.setSubmitting(false);
    } catch (err) {
      toastError(err);
    }
  }

  function _handleSubmit(values, actions) {
    if (isLastStep) {
      _submitForm(values, actions);
    } else {
      setActiveStep(activeStep + 1);
      actions.setTouched({});
      actions.setSubmitting(false);
    }
  }

  function _handleBack() {
    setActiveStep(activeStep - 1);
  }

  const handleCloseSuccess = () => {
    setShowSuccess(false);
    window.location.href = "/";
  };

  return (
    <div className={classes.root}>
      <div className={classes.header}>
        <Typography component="h1" variant="h4" className={classes.headerTitle}>
          Proses Pembayaran
        </Typography>
      </div>
      
      <Stepper activeStep={activeStep} className={classes.stepper}>
        {steps.map((label) => (
          <Step key={label}>
            <StepLabel>{label}</StepLabel>
          </Step>
        ))}
      </Stepper>

      <React.Fragment>
        {activeStep === steps.length ? (
          <CheckoutSuccess pix={datePayment} />
        ) : (
          <Formik
            initialValues={{
              ...user, 
              ...formInitialValues
            }}
            validationSchema={currentValidationSchema}
            onSubmit={_handleSubmit}
          >
            {({ isSubmitting, setFieldValue, values }) => (
              <Form id={formId}>
                {_renderStepContent(activeStep, setFieldValue, setActiveStep, values)}

                <div className={classes.buttons}>
                  {activeStep !== 1 && (
                    <Button onClick={_handleBack} className={classes.button}>
                      KEMBALI
                    </Button>
                  )}
                  <div className={classes.wrapper}>
                    {activeStep !== 1 && (
                      <Button
                        disabled={isSubmitting}
                        type="submit"
                        variant="contained"
                        color="primary"
                        className={classes.button}
                      >
                        {isLastStep ? "BAYAR" : "LANJUT"}
                      </Button>
                    )}
                    {isSubmitting && (
                      <CircularProgress
                        size={24}
                        className={classes.buttonProgress}
                      />
                    )}
                  </div>
                </div>
              </Form>
            )}
          </Formik>
        )}
      </React.Fragment>

      <Dialog
        open={showSuccess}
        onClose={handleCloseSuccess}
        maxWidth="sm"
        fullWidth
      >
        <DialogContent className={classes.successDialog}>
          <FaCheckCircle className={classes.successIcon} />
          <Typography variant="h5" gutterBottom>
            Pembayaran Berhasil!
          </Typography>
          <Typography variant="body1">
            Terima kasih atas pembayaran Anda. Subscription Anda telah diaktifkan.
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseSuccess} color="primary" variant="contained">
            Kembali ke Dashboard
          </Button>
        </DialogActions>
      </Dialog>
    </div>
  );
}
