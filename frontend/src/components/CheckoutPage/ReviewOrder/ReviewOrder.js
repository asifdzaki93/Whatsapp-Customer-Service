import React from 'react';
import { useFormikContext } from 'formik';
import { Typography, Paper, makeStyles, Grid } from '@material-ui/core';
import ShippingDetails from './ShippingDetails';
import PaymentDetails from './PaymentDetails';

const useStyles = makeStyles((theme) => ({
  container: {
    marginTop: theme.spacing(2),
  },
  paper: {
    padding: theme.spacing(3),
    marginBottom: theme.spacing(3),
  },
  title: {
    color: theme.palette.primary.main,
    fontWeight: 600,
    marginBottom: theme.spacing(3),
  },
  subtitle: {
    color: theme.palette.text.secondary,
    marginBottom: theme.spacing(2),
  }
}));

export default function ReviewOrder() {
  const { values: formValues } = useFormikContext();
  const classes = useStyles();
  
  return (
    <div className={classes.container}>
      <Paper className={classes.paper}>
        <Typography variant="h5" className={classes.title}>
          Ringkasan Pembayaran
        </Typography>
        <Typography variant="subtitle1" className={classes.subtitle}>
          Silakan periksa detail pembayaran Anda sebelum melanjutkan
        </Typography>
        <ShippingDetails formValues={formValues} />
      </Paper>

      <Paper className={classes.paper}>
        <Typography variant="h5" className={classes.title}>
          Detail Pembayaran
        </Typography>
        <PaymentDetails formValues={formValues} />
      </Paper>
    </div>
  );
}
