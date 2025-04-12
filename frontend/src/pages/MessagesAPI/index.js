import React, { useState } from "react";
import axios from "axios";
import { makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";

import { i18n } from "../../translate/i18n";
import { Button, CircularProgress, Grid, TextField, Typography } from "@material-ui/core";
import { Field, Form, Formik } from "formik";
import toastError from "../../errors/toastError";
import { toast } from "react-toastify";
import api from "../../services/api";

const useStyles = makeStyles((theme) => ({
  mainPaper: {
    flex: 1,
    padding: theme.spacing(2),
    paddingBottom: 100
  },
  mainHeader: {
    marginTop: theme.spacing(1),
  },
  elementMargin: {
    marginTop: theme.spacing(2),
  },
  formContainer: {
    maxWidth: 500,
  },
  textRight: {
    textAlign: "right"
  }
}));

const MessagesAPI = () => {
  const classes = useStyles();

  const [formMessageTextData,] = useState({ token: '',number: '', body: '' })
  const [formMessageMediaData,] = useState({ token: '', number: '', medias: '' })
  const [file, setFile] = useState({})

  const getEndpoint = () => {
    return process.env.REACT_APP_BACKEND_URL + '/api/messages/send'
  }

  const handleSendTextMessage = async (values) => {
    const { number, body } = values;
    const data = { number, body };
    var options = {
      method: 'POST',
      url: `${process.env.REACT_APP_BACKEND_URL}/api/messages/send`,
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${values.token}`
      },
      data
    };
    
    axios.request(options).then(function (response) {
      toast.success('Pesan berhasil dikirim');
    }).catch(function (error) {
      toastError(error);
    });    
  }

  const handleSendMediaMessage = async (values) => { 
    try {
      const firstFile = file[0];
      const data = new FormData();
      data.append('number', values.number);
      data.append('body', firstFile.name);
      data.append('medias', firstFile);
      var options = {
        method: 'POST',
        url: `${process.env.REACT_APP_BACKEND_URL}/api/messages/send`,
        headers: {
          'Content-Type': 'multipart/form-data',
          Authorization: `Bearer ${values.token}`
        },
        data
      };
      
      axios.request(options).then(function (response) {
        toast.success('Media berhasil dikirim');
      }).catch(function (error) {
        toastError(error);
      });      
    } catch (err) {
      toastError(err);
    }
  }

  const renderFormMessageText = () => {
    return (
      <Formik
        initialValues={formMessageTextData}
        enableReinitialize={true}
        onSubmit={(values, actions) => {
          setTimeout(async () => {
            await handleSendTextMessage(values);
            actions.setSubmitting(false);
            actions.resetForm()
          }, 400);
        }}
        className={classes.elementMargin}
      >
        {({ isSubmitting }) => (
          <Form className={classes.formContainer}>
            <Grid container spacing={2}>
              <Grid item xs={12} md={6}>
                <Field
                  as={TextField}
                  label={i18n.t("messagesAPI.textMessage.token")}
                  name="token"
                  autoFocus
                  variant="outlined"
                  margin="dense"
                  fullWidth
                  className={classes.textField}
                  required
                />
              </Grid>
              <Grid item xs={12} md={6}>
                <Field
                  as={TextField}
                  label={i18n.t("messagesAPI.textMessage.number")}
                  name="number"
                  autoFocus
                  variant="outlined"
                  margin="dense"
                  fullWidth
                  className={classes.textField}
                  required
                />
              </Grid>
              <Grid item xs={12}>
                <Field
                  as={TextField}
                  label={i18n.t("messagesAPI.textMessage.body")}
                  name="body"
                  autoFocus
                  variant="outlined"
                  margin="dense"
                  fullWidth
                  className={classes.textField}
                  required
                />
              </Grid>
              <Grid item xs={12} className={classes.textRight}>
                <Button
									type="submit"
									color="primary"
									variant="contained"
									className={classes.btnWrapper}
								>
									{isSubmitting ? (
										<CircularProgress
											size={24}
											className={classes.buttonProgress}
										/>
									) : 'Kirim'}
								</Button>
              </Grid>
            </Grid>
          </Form>
        )}
      </Formik>
    )
  }

  const renderFormMessageMedia = () => {
    return (
      <Formik
        initialValues={formMessageMediaData}
        enableReinitialize={true}
        onSubmit={(values, actions) => {
          setTimeout(async () => {
           
            await handleSendMediaMessage(values);
            actions.setSubmitting(false);
            actions.resetForm()
            document.getElementById('medias').files = null
            document.getElementById('medias').value = null
          }, 400);
        }}
        className={classes.elementMargin}
      >
        {({ isSubmitting }) => (
          <Form className={classes.formContainer}>
            <Grid container spacing={2}>
              <Grid item xs={12} md={6}>
                <Field
                  as={TextField}
                  label={i18n.t("messagesAPI.mediaMessage.token")}
                  name="token"
                  autoFocus
                  variant="outlined"
                  margin="dense"
                  fullWidth
                  className={classes.textField}
                  required
                />
              </Grid>
              <Grid item xs={12} md={6}>
                <Field
                  as={TextField}
                  label={i18n.t("messagesAPI.mediaMessage.number")}
                  name="number"
                  autoFocus
                  variant="outlined"
                  margin="dense"
                  fullWidth
                  className={classes.textField}
                  required
                />
              </Grid>
              <Grid item xs={12}>
                <input type="file" name="medias" id="medias" required onChange={(e) => setFile(e.target.files)} />
              </Grid>
              <Grid item xs={12} className={classes.textRight}>
                <Button
									type="submit"
									color="primary"
									variant="contained"
									className={classes.btnWrapper}
								>
									{isSubmitting ? (
										<CircularProgress
											size={24}
											className={classes.buttonProgress}
										/>
									) : 'Kirim'}
								</Button>
              </Grid>
            </Grid>
          </Form>
        )}
      </Formik>
    )
  }

  return (
    <Paper className={classes.mainPaper} variant="outlined">
      <Typography variant="h5" gutterBottom>
        Dokumentasi API Pengiriman Pesan
      </Typography>

      <Typography variant="h6" color="primary" className={classes.elementMargin}>
        Metode Pengiriman
      </Typography>
      <Typography component="div">
        <ol>
          <li>Pesan Teks</li>
          <li>Pesan Media</li>
        </ol>
      </Typography>

      <Typography variant="h6" color="primary" className={classes.elementMargin}>
        Petunjuk Penggunaan
      </Typography>
      <Typography className={classes.elementMargin} component="div">
        <b>Catatan Penting</b><br />
        <ul>
          <li>
            Sebelum mengirim pesan, Anda harus mendaftarkan token yang terhubung ke koneksi pengirim pesan.
            <br/>
            Untuk mendaftar, buka menu "Koneksi", klik tombol edit pada koneksi dan masukkan token pada kolom yang tersedia.
          </li>
          <li>
            Format nomor tujuan harus tanpa karakter khusus dan terdiri dari:
            <ul>
              <li>Kode Negara</li>
              <li>Kode Area</li>
              <li>Nomor Telepon</li>
            </ul>
          </li>
        </ul>
      </Typography>

      <Typography variant="h6" color="primary" className={classes.elementMargin}>
        1. Pesan Teks
      </Typography>
      <Grid container spacing={3}>
        <Grid item xs={12} sm={6}>
          <Paper variant="outlined" style={{ padding: 16 }}>
            <Typography component="div">
              <p>Informasi yang diperlukan untuk mengirim pesan teks:</p>
              <b>Endpoint:</b> {getEndpoint()} <br />
              <b>Metode:</b> POST <br />
              <b>Headers:</b> 
              <ul>
                <li>X_TOKEN: token yang terdaftar</li>
                <li>Content-Type: application/json</li>
              </ul>
              <b>Body:</b> <pre>{"{\n  \"number\": \"628123456789\",\n  \"body\": \"Pesan Anda\"\n}"}</pre>
            </Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} sm={6}>
          <Paper variant="outlined" style={{ padding: 16 }}>
            <Typography variant="subtitle1" gutterBottom>
              <b>Uji Pengiriman</b>
            </Typography>
            {renderFormMessageText()}
          </Paper>
        </Grid>
      </Grid>

      <Typography variant="h6" color="primary" className={classes.elementMargin}>
        2. Pesan Media
      </Typography>
      <Grid container spacing={3}>
        <Grid item xs={12} sm={6}>
          <Paper variant="outlined" style={{ padding: 16 }}>
            <Typography component="div">
              <p>Informasi yang diperlukan untuk mengirim pesan media:</p>
              <b>Endpoint:</b> {getEndpoint()} <br />
              <b>Metode:</b> POST <br />
              <b>Headers:</b>
              <ul>
                <li>X_TOKEN: token yang terdaftar</li>
                <li>Content-Type: multipart/form-data</li>
              </ul>
              <b>FormData:</b>
              <ul>
                <li><b>number:</b> 628123456789</li>
                <li><b>medias:</b> file</li>
              </ul>
            </Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} sm={6}>
          <Paper variant="outlined" style={{ padding: 16 }}>
            <Typography variant="subtitle1" gutterBottom>
              <b>Uji Pengiriman</b>
            </Typography>
            {renderFormMessageMedia()}
          </Paper>
        </Grid>
      </Grid>
    </Paper>
  );
};

export default MessagesAPI;