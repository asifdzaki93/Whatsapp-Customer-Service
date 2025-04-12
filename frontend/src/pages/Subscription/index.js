import React, { useState, useContext, useEffect } from "react";
import { makeStyles } from "@material-ui/core/styles";
import { toast } from "react-toastify";
import api from "../../services/api";

import Paper from "@material-ui/core/Paper";
import Button from "@material-ui/core/Button";
import Grid from '@material-ui/core/Grid';
import TextField from '@material-ui/core/TextField';
import Typography from '@material-ui/core/Typography';

import SubscriptionModal from "../../components/SubscriptionModal";
import MainHeader from "../../components/MainHeader";
import Title from "../../components/Title";
import MainContainer from "../../components/MainContainer";

import { AuthContext } from "../../context/Auth/AuthContext";

const useStyles = makeStyles((theme) => ({
  mainPaper: {
    flex: 1,
    padding: theme.spacing(1),
    overflowY: "scroll",
    ...theme.scrollbarStyles,
  },
  plansContainer: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(250px, 1fr))",
    gap: theme.spacing(2),
    padding: theme.spacing(2),
  },
  planCard: {
    border: `1px solid ${theme.palette.divider}`,
    borderRadius: theme.shape.borderRadius,
    padding: theme.spacing(2),
    textAlign: "center",
    transition: "all 0.3s ease",
    "&:hover": {
      boxShadow: theme.shadows[4],
      transform: "translateY(-4px)",
    },
  },
  planTitle: {
    fontSize: "1.5rem",
    fontWeight: "bold",
    marginBottom: theme.spacing(2),
  },
  planPrice: {
    fontSize: "2rem",
    color: theme.palette.primary.main,
    marginBottom: theme.spacing(2),
  },
  planFeature: {
    margin: theme.spacing(1, 0),
    color: theme.palette.text.secondary,
  },
  subscribeButton: {
    marginTop: theme.spacing(2),
    width: "100%",
  },
}));

const _formatDate = (date) => {
  const now = new Date();
  const past = new Date(date);
  const diff = Math.abs(now.getTime() - past.getTime());
  const days = Math.ceil(diff / (1000 * 60 * 60 * 24));

  return days;
}

const Subscription = () => {
  const classes = useStyles();
  const { user } = useContext(AuthContext);

  const [loading, setLoading] = useState(false);
  const [plans, setPlans] = useState([]);
  const [selectedContactId, setSelectedContactId] = useState(null);
  const [contactModalOpen, setContactModalOpen] = useState(false);
  const [hasMore,] = useState(false);

  useEffect(() => {
    loadPlans();
  }, []);

  const loadPlans = async () => {
    try {
      const { data } = await api.get("/subscription/plans");
      setPlans(data);
    } catch (err) {
      toast.error("Error loading plans");
    }
  };

  const handleSubscription = async (plan) => {
    try {
      setLoading(true);
      
      // Log plan data untuk debugging
      console.log('Selected plan:', plan);
      
      // Tampilkan detail langganan yang dipilih
      const detailSubscription = {
        name: plan.name,
        price: plan.price,
        users: plan.users,
        connections: plan.connections,
        queues: plan.queues
      };

      // Log detail subscription untuk debugging
      console.log('Detail subscription:', detailSubscription);

      // Konfirmasi pembayaran
      const confirmed = window.confirm(
        `Detail Langganan:\n
        Paket: ${detailSubscription.name}\n
        Harga: Rp${detailSubscription.price}/bulan\n
        Jumlah Pengguna: ${detailSubscription.users}\n
        Jumlah Koneksi: ${detailSubscription.connections}\n
        Jumlah Antrian: ${detailSubscription.queues}\n\n
        Klik OK untuk melanjutkan pembayaran`
      );

      if (!confirmed) {
        setLoading(false);
        return;
      }

      // Siapkan data untuk dikirim ke backend
      const paymentData = {
        planId: plan.id,
        price: Number(plan.price),
        users: Number(plan.users),
        connections: Number(plan.connections),
        queues: Number(plan.queues),
        email: user.email,
        name: user.name,
        phone: user.phone
      };

      // Log payment data untuk debugging
      console.log('Payment data:', paymentData);

      // Buat transaksi di backend
      const { data } = await api.post("/subscription/payment", paymentData);

      // Pastikan window.snap tersedia
      if (typeof window.snap === 'undefined') {
        toast.error("Error: Midtrans Snap tidak tersedia");
        return;
      }

      // Tampilkan Snap popup
      window.snap.pay(data.token, {
        onSuccess: function(result) {
          toast.success("Pembayaran berhasil!");
          window.location.href = "/subscription/success";
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
    } catch (err) {
      console.error('Subscription error:', err);
      toast.error(err.response?.data?.message || "Error saat membuat subscription");
    } finally {
      setLoading(false);
    }
  };

  const handleOpenContactModal = (plan) => {
    setSelectedContactId(null);
    setContactModalOpen(true);
  };

  const handleCloseContactModal = () => {
    setSelectedContactId(null);
    setContactModalOpen(false);
  };

  const loadMore = () => {
    // Implementasi loadMore
  };

  const handleScroll = (e) => {
    if (!hasMore || loading) return;
    const { scrollTop, scrollHeight, clientHeight } = e.currentTarget;
    if (scrollHeight - (scrollTop + 100) < clientHeight) {
      loadMore();
    }
  };

  return (
    <MainContainer className={classes.mainContainer}>
      <SubscriptionModal
        open={contactModalOpen}
        onClose={handleCloseContactModal}
        aria-labelledby="form-dialog-title"
        contactId={selectedContactId}
        plan={plans[0]}
      />

      <MainHeader>
        <Title>Berlangganan</Title>
      </MainHeader>
      <Grid item xs={12} sm={4}>
        <Paper
          className={classes.mainPaper}
          variant="outlined"
          onScroll={handleScroll}
        >
          <div>
            <TextField
              id="outlined-full-width"
              label="Masa Uji Coba"
              defaultValue={`Masa uji coba Anda berakhir dalam ${_formatDate(user?.company?.trialExpiration)} hari!`}
              fullWidth
              margin="normal"
              InputLabelProps={{
                shrink: true,
              }}
              InputProps={{
                readOnly: true,
              }}
              variant="outlined"
            />
          </div>

          <div>
            <TextField
              id="outlined-full-width"
              label="Email Penagihan"
              defaultValue={user?.company?.email}
              fullWidth
              margin="normal"
              InputLabelProps={{
                shrink: true,
              }}
              InputProps={{
                readOnly: true,
              }}
              variant="outlined"
            />
          </div>

          <div className={classes.plansContainer}>
            {plans.map((plan) => (
              <div key={plan.id} className={classes.planCard}>
                <Typography variant="h5" className={classes.planTitle}>
                  {plan.name}
                </Typography>
                <Typography variant="h4" className={classes.planPrice}>
                  Rp{plan.price}
                  <Typography variant="subtitle1" component="span">
                    /bulan
                  </Typography>
                </Typography>
                <Typography className={classes.planFeature}>
                  {plan.users} Pengguna
                </Typography>
                <Typography className={classes.planFeature}>
                  {plan.connections} Koneksi
                </Typography>
                <Typography className={classes.planFeature}>
                  {plan.queues} Antrian
                </Typography>
                <Button
                  variant="contained"
                  color="primary"
                  className={classes.subscribeButton}
                  onClick={() => handleOpenContactModal(plan)}
                  disabled={loading}
                >
                  {loading ? "Memproses..." : "Berlangganan"}
                </Button>
              </div>
            ))}
          </div>
        </Paper>
      </Grid>
    </MainContainer>
  );
};

export default Subscription;
