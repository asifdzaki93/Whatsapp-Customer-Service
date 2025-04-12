import React, { useState, useEffect, useCallback, useMemo } from "react";
import { toast } from "react-toastify";
import {
  makeStyles,
  Paper,
  Grid,
  Typography,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Snackbar,
  SnackbarContent,
  FormControl,
  Select,
  MenuItem,
} from "@material-ui/core";
import {
  Assessment as AssessmentIcon,
  Payment as PaymentIcon,
  ArrowUpward as UpgradeIcon,
  ArrowDownward as DowngradeIcon,
  Cancel as CancelIcon,
  History as HistoryIcon,
  Autorenew as AutorenewIcon,
  Delete as DeleteIcon,
} from "@material-ui/icons";

import MainContainer from "../../components/MainContainer";
import MainHeader from "../../components/MainHeader";
import Title from "../../components/Title";
import api from "../../services/api";
import { AuthContext } from "../../context/Auth/AuthContext";
import moment from "moment";

const useStyles = makeStyles((theme) => ({
  mainPaper: {
    flex: 1,
    padding: theme.spacing(2),
    margin: theme.spacing(1),
    height: "calc(100vh - 100px)",
    overflowY: "auto",
  },
  section: {
    marginBottom: theme.spacing(2),
    padding: theme.spacing(2),
    backgroundColor: theme.palette.background.paper,
    borderRadius: theme.shape.borderRadius,
  },
  currentPlanSection: {
    backgroundColor: theme.palette.background.paper,
    border: `2px solid ${theme.palette.primary.main}`,
    position: "relative",
    display: "flex",
    flexDirection: "column",
    height: "100%",
    "&::before": {
      content: '""',
      position: "absolute",
      top: 0,
      left: 0,
      right: 0,
      height: "4px",
      backgroundColor: theme.palette.primary.main,
      borderRadius: `${theme.shape.borderRadius}px ${theme.shape.borderRadius}px 0 0`,
    },
    "& .MuiTypography-subtitle1": {
      color: theme.palette.primary.main,
      fontWeight: "bold",
      marginBottom: theme.spacing(1),
    },
    "& .MuiTypography-h6": {
      marginBottom: theme.spacing(0.5),
    },
    "& .MuiTypography-subtitle1": {
      marginBottom: theme.spacing(0.5),
    },
    "& .MuiTypography-body2": {
      marginBottom: theme.spacing(1),
    }
  },
  currentPlanContent: {
    flex: 1,
    display: "flex",
    flexDirection: "column",
    justifyContent: "space-between",
    height: "100%",
  },
  currentPlanInfo: {
    flex: 1,
    display: "flex",
    flexDirection: "column",
    "& .MuiTypography-h6": {
      marginBottom: theme.spacing(0.5),
    },
    "& .MuiTypography-subtitle1": {
      marginBottom: theme.spacing(0.5),
    },
    "& .MuiTypography-body2": {
      marginBottom: theme.spacing(1),
    }
  },
  currentPlanFeatures: {
    marginTop: theme.spacing(1),
    "& .MuiTypography-root": {
      fontSize: "0.75rem",
      marginBottom: theme.spacing(0.25),
    }
  },
  plansContainer: {
    display: "grid",
    gridTemplateColumns: "1fr 2fr",
    gap: theme.spacing(2),
    marginBottom: theme.spacing(2),
    height: "100%",
  },
  plansListContainer: {
    position: "relative",
    overflow: "hidden",
    height: "100%",
  },
  plansList: {
    display: "flex",
    gap: theme.spacing(1),
    height: "100%",
    overflowX: "auto",
    scrollbarWidth: "thin",
    "&::-webkit-scrollbar": {
      height: "6px",
    },
    "&::-webkit-scrollbar-track": {
      background: theme.palette.divider,
      borderRadius: "3px",
    },
    "&::-webkit-scrollbar-thumb": {
      background: theme.palette.primary.main,
      borderRadius: "3px",
      "&:hover": {
        background: theme.palette.primary.dark,
      },
    },
  },
  planCard: {
    padding: theme.spacing(1.5),
    backgroundColor: theme.palette.background.paper,
    borderRadius: theme.shape.borderRadius,
    border: `1px solid ${theme.palette.divider}`,
    display: "flex",
    flexDirection: "column",
    height: "100%",
    minWidth: "300px",
    flex: "0 0 auto",
    "& .MuiTypography-h6": {
      fontSize: "0.875rem",
      marginBottom: theme.spacing(0.5),
    },
    "& .MuiTypography-h5": {
      fontSize: "1rem",
      marginBottom: theme.spacing(0.5),
    }
  },
  planFeatures: {
    flex: 1,
    marginTop: theme.spacing(0.5),
    "& .MuiTypography-root": {
      fontSize: "0.75rem",
      marginBottom: theme.spacing(0.25),
    },
    "& .MuiGrid-container": {
      marginTop: theme.spacing(0.5),
    }
  },
  actionButtons: {
    display: "flex",
    gap: theme.spacing(0.5),
    marginTop: "auto",
    paddingTop: theme.spacing(1),
  },
  statusActive: {
    color: theme.palette.success.main,
  },
  statusPending: {
    color: theme.palette.warning.main,
  },
  statusExpired: {
    color: theme.palette.error.main,
  },
  comparisonRow: {
    marginBottom: theme.spacing(0.5),
  },
  warnings: {
    marginTop: theme.spacing(1),
  },
  renewalDialog: {
    minWidth: 400
  },
  infoMessage: {
    backgroundColor: theme.palette.background.default,
    padding: theme.spacing(1),
    borderRadius: theme.shape.borderRadius,
  },
  currentPlanCard: {
    display: "flex",
    flexDirection: "column",
    padding: theme.spacing(1.5),
    backgroundColor: theme.palette.primary.light,
    color: theme.palette.primary.contrastText,
    height: "100%",
  },
  currentPlanActions: {
    display: "flex",
    gap: theme.spacing(1),
    marginTop: "auto",
  },
  companyInfo: {
    "& .MuiTypography-subtitle2": {
      fontSize: "0.75rem",
      marginBottom: theme.spacing(0.25),
    },
    "& .MuiTypography-body1": {
      fontSize: "0.875rem",
    }
  },
  paymentHistory: {
    "& .MuiTableCell-root": {
      padding: theme.spacing(1),
      fontSize: "0.875rem",
    },
    "& .MuiTableHead-root .MuiTableCell-root": {
      fontWeight: "bold",
    }
  }
}));

const PlanCard = React.memo(({ plan, isCurrentPlan, onUpgrade }) => {
  const classes = useStyles();
  
  const renderFeatures = useCallback(() => {
    if (!plan) return null;
    
    return (
      <div className={classes.planFeatures}>
        <Grid container spacing={1}>
          <Grid item xs={6}>
            <Typography>✓ {plan.users || 0} Pengguna</Typography>
            <Typography>✓ {plan.connections || 0} Koneksi</Typography>
            <Typography>✓ {plan.queues || 0} Antrian</Typography>
            {plan.useCampaigns && <Typography>✓ Fitur Kampanye</Typography>}
            {plan.useSchedules && <Typography>✓ Fitur Penjadwalan</Typography>}
          </Grid>
          <Grid item xs={6}>
            {plan.useInternalChat && <Typography>✓ Chat Internal</Typography>}
            {plan.useExternalApi && <Typography>✓ API Eksternal</Typography>}
            {plan.useKanban && <Typography>✓ Kanban</Typography>}
            {plan.useOpenAi && <Typography>✓ OpenAI Integration</Typography>}
            {plan.useIntegrations && <Typography>✓ Integrasi Lainnya</Typography>}
          </Grid>
        </Grid>
      </div>
    );
  }, [plan, classes.planFeatures]);

  return (
    <div className={classes.planCard}>
      <Typography variant="h6">{plan.name}</Typography>
      <Typography variant="h5">
        {formatCurrency(plan.value)}/bulan
      </Typography>
      {renderFeatures()}
      {isCurrentPlan ? (
        <Button
          variant="outlined"
          color="primary"
          disabled
          fullWidth
          size="small"
        >
          Aktif
        </Button>
      ) : (
        <Button
          variant="contained"
          color="primary"
          onClick={() => onUpgrade(plan.id)}
          fullWidth
          size="small"
        >
          Pilih Paket
        </Button>
      )}
    </div>
  );
});

const PaymentHistoryTable = React.memo(({ payments, onPay, onRenew }) => {
  const classes = useStyles();
  
  return (
    <TableContainer>
      <Table size="small" className={classes.paymentHistory}>
        <TableHead>
          <TableRow>
            <TableCell>Tanggal</TableCell>
            <TableCell>Detail</TableCell>
            <TableCell>Jumlah</TableCell>
            <TableCell>Status</TableCell>
            <TableCell>Aksi</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {payments.map((payment) => (
            <TableRow key={payment.id}>
              <TableCell>{moment(payment.createdAt).format("DD/MM/YYYY")}</TableCell>
              <TableCell>{payment.detail}</TableCell>
              <TableCell>{formatCurrency(payment.value)}</TableCell>
              <TableCell>{getStatusChip(payment.status)}</TableCell>
              <TableCell>
                {payment.status !== "paid" && (
                  <Button
                    size="small"
                    variant="outlined"
                    color="secondary"
                    onClick={() => onPay(payment.token)}
                  >
                    BAYAR
                  </Button>
                )}
                {moment(payment.dueDate).isBefore(moment()) && payment.status === "pending" && (
                  <IconButton
                    size="small"
                    color="primary"
                    onClick={() => onRenew(payment)}
                  >
                    <AutorenewIcon />
                  </IconButton>
                )}
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  );
});

const formatCurrency = (value) => {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(value);
};

const getStatusChip = (status) => {
  switch (status) {
    case "paid":
      return <Chip label="Lunas" color="primary" />;
    case "pending":
      return <Chip label="Menunggu Pembayaran" color="secondary" />;
    default:
      return <Chip label="Belum Lunas" color="secondary" />;
  }
};

const SubscriptionDashboard = () => {
  const classes = useStyles();
  const { user } = React.useContext(AuthContext);
  const [currentPlan, setCurrentPlan] = useState(null);
  const [availablePlans, setAvailablePlans] = useState([]);
  const [paymentHistory, setPaymentHistory] = useState([]);
  const [openDialog, setOpenDialog] = useState({ 
    upgrade: false, 
    cancel: false, 
    renewal: false 
  });
  const [selectedPlan, setSelectedPlan] = useState("");
  const [loading, setLoading] = useState(false);
  const [currentSubscription, setCurrentSubscription] = useState(null);

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      const [{ data: plans }, { data: history }, { data: companies }] = await Promise.all([
        api.get("/plans/list"),
        api.get("/invoices/all"),
        api.get("/companies/list")
      ]);

      setAvailablePlans(Array.isArray(plans) ? plans : []);
      setPaymentHistory(Array.isArray(history) ? history : []);
      
      const currentCompany = companies.find(company => company.id === user.companyId);
      setCurrentSubscription(currentCompany);
      if (currentCompany?.plan) {
        setCurrentPlan(currentCompany.plan);
      }
    } catch (err) {
      console.error("Error fetching data:", err);
      toast.error("Gagal memuat data");
    } finally {
      setLoading(false);
    }
  }, [user.companyId]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const handleUpgrade = useCallback(async (planId) => {
    try {
      const { data } = await api.post("/subscription/upgrade", { planId });
      if (data.token) {
        window.snap.pay(data.token);
      }
      setOpenDialog(prev => ({ ...prev, upgrade: false }));
      fetchData();
    } catch (err) {
      toast.error("Gagal melakukan upgrade");
    }
  }, [fetchData]);

  const handleCancel = useCallback(async () => {
    try {
      await api.post("/subscription/cancel");
      toast.success("Langganan berhasil dibatalkan");
      setOpenDialog(prev => ({ ...prev, cancel: false }));
      fetchData();
    } catch (err) {
      toast.error("Gagal membatalkan langganan");
    }
  }, [fetchData]);

  const handleRenewal = useCallback(async () => {
    if (!selectedPlan) {
      toast.error("Silakan pilih paket langganan");
      return;
    }

    try {
      const plan = availablePlans.find(p => p.id === selectedPlan);
      const { data } = await api.post("/invoices", {
        companyId: user.companyId,
        detail: `Perpanjangan - ${plan.name}`,
        value: plan.value,
        dueDate: new Date(Date.now() + 86400000).toISOString(),
        status: "pending"
      });

      toast.success("Invoice perpanjangan berhasil dibuat");
      setOpenDialog(prev => ({ ...prev, renewal: false }));
      fetchData();
    } catch (err) {
      toast.error("Gagal membuat invoice perpanjangan");
    }
  }, [selectedPlan, availablePlans, user.companyId, fetchData]);

  const handlePay = useCallback((token) => {
    window.snap.pay(token);
  }, []);

  const handleRenew = useCallback((payment) => {
    setSelectedPlan(currentPlan?.id);
    setOpenDialog(prev => ({ ...prev, renewal: true }));
  }, [currentPlan?.id]);

  const handleDialogClose = useCallback((dialogType) => {
    setOpenDialog(prev => ({ ...prev, [dialogType]: false }));
  }, []);

  return (
    <MainContainer>
      <MainHeader>
        <Title>Dashboard Langganan</Title>
      </MainHeader>

      <Paper className={classes.mainPaper}>
        {loading ? (
          <Typography>Memuat data...</Typography>
        ) : (
          <>
            {/* Company Info */}
            <div className={classes.section}>
              {currentSubscription ? (
                <Grid container spacing={2}>
                  <Grid item xs={12} sm={6} md={3}>
                    <Typography variant="subtitle2" color="textSecondary">
                      Nama Perusahaan
                    </Typography>
                    <Typography variant="body1">
                      {currentSubscription.name}
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6} md={3}>
                    <Typography variant="subtitle2" color="textSecondary">
                      Status
                    </Typography>
                    <Chip 
                      label={currentSubscription.status ? "Aktif" : "Tidak Aktif"} 
                      color={currentSubscription.status ? "primary" : "secondary"}
                      size="small"
                    />
                  </Grid>
                  <Grid item xs={12} sm={6} md={3}>
                    <Typography variant="subtitle2" color="textSecondary">
                      Jatuh Tempo
                    </Typography>
                    <Typography variant="body1">
                      {moment(currentSubscription.dueDate).format("DD/MM/YYYY")}
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6} md={3}>
                    <Typography variant="subtitle2" color="textSecondary">
                      Periode
                    </Typography>
                    <Typography variant="body1">
                      {currentSubscription.recurrence}
                    </Typography>
                  </Grid>
                </Grid>
              ) : (
                <SnackbarContent
                  message="Data perusahaan tidak tersedia"
                  className={classes.infoMessage}
                />
              )}
            </div>

            {/* Plans Section */}
            <div className={classes.section}>
              <Typography variant="h6" gutterBottom>
                Paket Langganan
              </Typography>
              <div className={classes.plansContainer}>
                {/* Current Plan */}
                <div className={`${classes.section} ${classes.currentPlanSection}`}>
                  <Typography variant="subtitle1" gutterBottom>
                    Paket Saat Ini
                  </Typography>
                  {currentPlan ? (
                    <div className={classes.currentPlanContent}>
                      <div className={classes.currentPlanInfo}>
                        <Typography variant="h6">
                          {currentPlan.name}
                        </Typography>
                        <Typography variant="subtitle1">
                          {formatCurrency(currentPlan.value)}/bulan
                        </Typography>
                        <Typography variant="body2">
                          {currentPlan.users ? `${currentPlan.users} Pengguna` : '0 Pengguna'} • {currentPlan.connections ? `${currentPlan.connections} Koneksi` : '0 Koneksi'} • {currentPlan.queues ? `${currentPlan.queues} Antrian` : '0 Antrian'}
                        </Typography>

                      </div>
                      <div className={classes.actionButtons}>
                        <Button
                          variant="contained"
                          color="secondary"
                          startIcon={<UpgradeIcon />}
                          onClick={() => setOpenDialog(prev => ({ ...prev, upgrade: true }))}
                          fullWidth
                          size="small"
                        >
                          Upgrade
                        </Button>
                        <Button
                          variant="outlined"
                          color="secondary"
                          startIcon={<CancelIcon />}
                          onClick={() => setOpenDialog(prev => ({ ...prev, cancel: true }))}
                          fullWidth
                          size="small"
                        >
                          Batalkan
                        </Button>
                      </div>
                    </div>
                  ) : (
                    <Typography variant="body2">
                      Belum ada paket aktif
                    </Typography>
                  )}
                </div>

                {/* Available Plans */}
                <div className={classes.plansListContainer}>
                  <div className={classes.plansList}>
                    {availablePlans.map((plan) => (
                      <PlanCard
                        key={plan.id}
                        plan={plan}
                        isCurrentPlan={plan.id === currentPlan?.id}
                        onUpgrade={handleUpgrade}
                      />
                    ))}
                  </div>
                </div>
              </div>
            </div>

            {/* Payment History */}
            <div className={classes.section}>
              <Typography variant="h6" gutterBottom>
                Riwayat Pembayaran
              </Typography>
              {paymentHistory.length > 0 ? (
                <PaymentHistoryTable
                  payments={paymentHistory}
                  onPay={handlePay}
                  onRenew={handleRenew}
                />
              ) : (
                <SnackbarContent
                  message="Belum ada riwayat pembayaran"
                  className={classes.infoMessage}
                />
              )}
            </div>
          </>
        )}
      </Paper>

      {/* Dialogs */}
      <Dialog open={openDialog.upgrade} onClose={() => handleDialogClose('upgrade')}>
        <DialogTitle>Pilih Paket Upgrade</DialogTitle>
        <DialogContent>
          {availablePlans
            .filter(plan => plan.value > (currentPlan?.value || 0))
            .map(plan => (
              <PlanCard
                key={plan.id}
                plan={plan}
                isCurrentPlan={false}
                onUpgrade={handleUpgrade}
              />
            ))}
        </DialogContent>
      </Dialog>

      <Dialog open={openDialog.cancel} onClose={() => handleDialogClose('cancel')}>
        <DialogTitle>Batalkan Langganan?</DialogTitle>
        <DialogContent>
          <Typography>
            Anda yakin ingin membatalkan langganan? Akses ke fitur premium akan dihentikan
            pada akhir periode langganan saat ini.
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => handleDialogClose('cancel')}>
            Batal
          </Button>
          <Button onClick={handleCancel} color="secondary" variant="contained">
            Ya, Batalkan
          </Button>
        </DialogActions>
      </Dialog>

      <Dialog 
        open={openDialog.renewal} 
        onClose={() => handleDialogClose('renewal')}
        classes={{ paper: classes.renewalDialog }}
      >
        <DialogTitle>Perpanjangan Langganan</DialogTitle>
        <DialogContent>
          <FormControl fullWidth margin="normal">
            <Select
              value={selectedPlan}
              onChange={(e) => setSelectedPlan(e.target.value)}
              displayEmpty
            >
              <MenuItem value="" disabled>
                Pilih Paket Langganan
              </MenuItem>
              {availablePlans.map((plan) => (
                <MenuItem key={plan.id} value={plan.id}>
                  {plan.name} - {plan.users} Pengguna, {plan.connections} Koneksi
                </MenuItem>
              ))}
            </Select>
          </FormControl>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => handleDialogClose('renewal')} color="secondary">
            Batal
          </Button>
          <Button onClick={handleRenewal} color="primary">
            Buat Invoice
          </Button>
        </DialogActions>
      </Dialog>
    </MainContainer>
  );
};

export default React.memo(SubscriptionDashboard);
