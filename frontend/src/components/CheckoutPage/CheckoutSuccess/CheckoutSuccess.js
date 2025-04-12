import React from 'react';
import { useHistory } from "react-router-dom";
import { SuccessContent } from './style';
import { FaCheckCircle } from 'react-icons/fa';
import { Typography, Button } from '@material-ui/core';

function CheckoutSuccess() {
  const history = useHistory();

  return (
    <SuccessContent>
      <FaCheckCircle size={48} color="#4CAF50" />
      <Typography variant="h5" style={{ marginTop: 20 }}>
        Pembayaran Berhasil!
      </Typography>
      <Typography variant="body1" style={{ marginTop: 10 }}>
        Terima kasih atas pembayaran Anda. 
        Subscription Anda telah diaktifkan.
      </Typography>
      <Button
        variant="contained"
        color="primary"
        onClick={() => history.push("/")}
        style={{ marginTop: 20 }}
      >
        Kembali ke Dashboard
      </Button>
    </SuccessContent>
  );
}

export default CheckoutSuccess;
