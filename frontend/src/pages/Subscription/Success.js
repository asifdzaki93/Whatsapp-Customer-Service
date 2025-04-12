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

const Success = () => {
  const classes = useStyles();
  const history = useHistory();

  useEffect(() => {
    toast.success("Payment successful! Your subscription has been activated.");
    setTimeout(() => {
      history.push("/dashboard");
    }, 3000);
  }, [history]);

  return (
    <div className={classes.container}>
      <Paper className={classes.paper}>
        <Typography variant="h4" className={classes.title}>
          Payment Successful!
        </Typography>
        <Typography variant="body1" className={classes.message}>
          Thank you for your subscription. Your account has been activated.
          You will be redirected to dashboard in a few seconds.
        </Typography>
        <Button
          variant="contained"
          color="primary"
          onClick={() => history.push("/dashboard")}
          className={classes.button}
        >
          Go to Dashboard
        </Button>
      </Paper>
    </div>
  );
};

export default Success; 