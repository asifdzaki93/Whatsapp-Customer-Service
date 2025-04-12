import React from 'react';
import { Typography, makeStyles } from '@material-ui/core';

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
  fullWidth: {
    gridColumn: '1 / -1',
  }
}));

function ShippingDetails(props) {
  const { formValues } = props;
  const classes = useStyles();
  const { address2, city, state, zipcode, country } = formValues;

  return (
    <div className={classes.container}>
      <div className={`${classes.section} ${classes.fullWidth}`}>
        <Typography className={classes.title}>Alamat Lengkap</Typography>
        <Typography className={classes.value}>{address2}</Typography>
      </div>
      <div className={classes.section}>
        <Typography className={classes.title}>Kota</Typography>
        <Typography className={classes.value}>{city}</Typography>
      </div>
      <div className={classes.section}>
        <Typography className={classes.title}>Provinsi</Typography>
        <Typography className={classes.value}>{state}</Typography>
      </div>
      <div className={classes.section}>
        <Typography className={classes.title}>Kode Pos</Typography>
        <Typography className={classes.value}>{zipcode}</Typography>
      </div>
      <div className={classes.section}>
        <Typography className={classes.title}>Negara</Typography>
        <Typography className={classes.value}>{country}</Typography>
      </div>
    </div>
  );
}

export default ShippingDetails;
