import React, {useContext} from 'react';
import { Typography, makeStyles } from '@material-ui/core';
import { AuthContext } from "../../../context/Auth/AuthContext";

const useStyles = makeStyles((theme) => ({
  container: {
    display: 'grid',
    gridTemplateColumns: '1fr 1fr',
    gap: theme.spacing(2),
  },
  section: {
    backgroundColor: theme.palette.background.paper,
    padding: theme.spacing(2),
    borderRadius: theme.shape.borderRadius,
  },
  title: {
    fontSize: '0.9rem',
    color: theme.palette.text.secondary,
    marginBottom: theme.spacing(1),
  },
  value: {
    fontSize: '1rem',
    fontWeight: 500,
  },
  total: {
    gridColumn: '1 / -1',
    backgroundColor: theme.palette.primary.main,
    color: theme.palette.primary.contrastText,
    padding: theme.spacing(2),
    borderRadius: theme.shape.borderRadius,
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  }
}));

function PaymentDetails(props) {
  const { formValues } = props;
  const classes = useStyles();
  const { user } = useContext(AuthContext);
  const plan = JSON.parse(formValues.plan);
  const { price, users, connections, queues } = plan;

  return (
    <div className={classes.container}>
      <div className={classes.section}>
        <Typography className={classes.title}>Email</Typography>
        <Typography className={classes.value}>{user.email}</Typography>
      </div>
      <div className={classes.section}>
        <Typography className={classes.title}>Nama</Typography>
        <Typography className={classes.value}>{user.name}</Typography>
      </div>
      <div className={classes.section}>
        <Typography className={classes.title}>Jumlah Pengguna</Typography>
        <Typography className={classes.value}>{users} Pengguna</Typography>
      </div>
      <div className={classes.section}>
        <Typography className={classes.title}>Jumlah Koneksi</Typography>
        <Typography className={classes.value}>{connections} Koneksi</Typography>
      </div>
      <div className={classes.section}>
        <Typography className={classes.title}>Jumlah Antrian</Typography>
        <Typography className={classes.value}>{queues} Antrian</Typography>
      </div>
      <div className={classes.total}>
        <Typography>Total Pembayaran</Typography>
        <Typography>Rp{price.toLocaleString('id-ID', {minimumFractionDigits: 2})}</Typography>
      </div>
    </div>
  );
}

export default PaymentDetails;
