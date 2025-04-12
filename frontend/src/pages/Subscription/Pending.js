import React, { useEffect } from "react";
import { useHistory } from "react-router-dom";
import { toast } from "react-toastify";
import { makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import Typography from "@material-ui/core/Typography";
import Button from "@material-ui/core/Button";

const useStyles = makeStyles((theme) => ({
  container: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    minHeight: "80vh",
    padding: theme.spacing(2),
  },
  paper: {
    padding: theme.spacing(4),
    textAlign: "center",
    maxWidth: 600,
    width: "100%",
  },
  title: {
    marginBottom: theme.spacing(2),
  },
  message: {
    marginBottom: theme.spacing(4),
  },
  button: {
    marginTop: theme.spacing(2),
  },
}));

const Pending = () => {
  const classes = useStyles();
  const history = useHistory();

  useEffect(() => {
    toast.info("Payment is pending. Please complete your payment.");
    setTimeout(() => {
      history.push("/subscription");
    }, 3000);
  }, [history]);

  return (
    <div className={classes.container}>
      <Paper className={classes.paper}>
        <Typography variant="h4" className={classes.title}>
          Payment Pending
        </Typography>
        <Typography variant="body1" className={classes.message}>
          Your payment is still being processed. Please complete the payment process.
          You will be redirected back to subscription page in a few seconds.
        </Typography>
        <Button
          variant="contained"
          color="primary"
          onClick={() => history.push("/subscription")}
          className={classes.button}
        >
          Back to Subscription
        </Button>
      </Paper>
    </div>
  );
};

export default Pending; 