import React, { useEffect, useRef } from "react";
import { makeStyles } from "@material-ui/core/styles";
import { green } from "@material-ui/core/colors";
import Dialog from "@material-ui/core/Dialog";
import DialogContent from "@material-ui/core/DialogContent";
import CheckoutPage from "../CheckoutPage/";
import api from "../../services/api";

const useStyles = makeStyles((theme) => ({
  root: {
    display: "flex",
    flexWrap: "wrap",
  },
  textField: {
    marginRight: theme.spacing(1),
    flex: 1,
  },
  extraAttr: {
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
  },
  btnWrapper: {
    position: "relative",
  },
  buttonProgress: {
    color: green[500],
    position: "absolute",
    top: "50%",
    left: "50%",
    marginTop: -12,
    marginLeft: -12,
  },
}));

const ContactModal = ({ open, onClose, plan, contactId, initialValues, onSave }) => {
  const classes = useStyles();
  const isMounted = useRef(true);

  useEffect(() => {
    return () => {
      isMounted.current = false;
    };
  }, []);

  const handleClose = () => {
    onClose();
  };

  const handlePayment = async (values) => {
    try {
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

      if (data.token) {
        window.snap.pay(data.token, {
          onSuccess: function(result) {
            window.location.href = data.redirect_url;
          },
          onPending: function(result) {
            window.location.href = data.redirect_url;
          },
          onError: function(result) {
            window.location.href = data.redirect_url;
          },
          onClose: function() {
            window.location.href = data.redirect_url;
          }
        });
      }
    } catch (err) {
      console.error(err);
    }
  };

  if (!plan) {
    return null;
  }

  return (
    <div className={classes.root}>
      <Dialog open={open} onClose={handleClose} maxWidth="md" scroll="paper">
        <DialogContent dividers>
          <CheckoutPage
            plan={plan}
            onSubmit={handlePayment}
          />
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default ContactModal;
