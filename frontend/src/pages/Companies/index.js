import React, { useState, useEffect } from "react";

import Avatar from "@material-ui/core/Avatar";
import Button from "@material-ui/core/Button";
import CssBaseline from "@material-ui/core/CssBaseline";
import FormControl from "@material-ui/core/FormControl";
import InputLabel from '@material-ui/core/InputLabel';
import TextField from "@material-ui/core/TextField";
import Select from "@material-ui/core/Select"
import MenuItem from "@material-ui/core/MenuItem"
import StoreIcon from "@material-ui/icons/Store";
import Grid from '@material-ui/core/Grid';
import Typography from "@material-ui/core/Typography";
import { makeStyles } from "@material-ui/core/styles";
import Container from "@material-ui/core/Container";

import { i18n } from "../../translate/i18n";
import useCompanies from '../../hooks/useCompanies';
import usePlans from '../../hooks/usePlans';
import { toast } from "react-toastify";
import toastError from "../../errors/toastError";
import { isEqual } from 'lodash'

const useStyles = makeStyles(theme => ({
	paper: {
		marginTop: theme.spacing(8),
		display: "flex",
		flexDirection: "column",
		alignItems: "center",
	},
	avatar: {
		margin: theme.spacing(1),
		backgroundColor: theme.palette.secondary.main,
	},
	form: {
		width: "100%", // Fix IE 11 issue.
		marginTop: theme.spacing(2),
	},
	submit: {
		margin: theme.spacing(3, 0, 2),
	}
}));

const FormCompany = () => {
	const classes = useStyles();
	const { loading, createCompany } = useCompanies();
	const { plans } = usePlans();
	const [company, setCompany] = useState({
		name: "",
		email: "",
		phone: "",
		status: true,
		planId: "",
		campaignsEnabled: false
	});

	const handleChangeInput = e => {
		const { name, value } = e.target;
		setCompany(prev => ({
			...prev,
			[name]: value
		}));
	};

	const handleSubmit = async e => {
		e.preventDefault();
		try {
			await createCompany(company);
			toast.success("Perusahaan berhasil ditambahkan!");
			setCompany({
				name: "",
				email: "",
				phone: "",
				status: true,
				planId: "",
				campaignsEnabled: false
			});
		} catch (err) {
			toastError(err);
		}
	};

	return (
		<Container component="main" maxWidth="xs">
			<CssBaseline />
			<div className={classes.paper}>
				<Avatar className={classes.avatar}>
					<StoreIcon />
				</Avatar>
				<Typography component="h1" variant="h5">
					Tambah Perusahaan
				</Typography>
				<form className={classes.form} onSubmit={handleSubmit}>
					<Grid container spacing={2}>
						<Grid item xs={12}>
							<TextField
								variant="outlined"
								required
								fullWidth
								id="name"
								label="Nama Perusahaan"
								name="name"
								value={company.name}
								onChange={handleChangeInput}
								autoComplete="name"
								autoFocus
								error={company.name.length > 0 && company.name.length < 2}
								helperText={company.name.length > 0 && company.name.length < 2 ? "Nama perusahaan minimal 2 karakter" : ""}
							/>
						</Grid>
						<Grid item xs={12}>
							<TextField
								variant="outlined"
								required
								fullWidth
								id="email"
								label="Email"
								name="email"
								type="email"
								value={company.email}
								onChange={handleChangeInput}
								autoComplete="email"
								error={company.email.length > 0 && !company.email.includes("@")}
								helperText={company.email.length > 0 && !company.email.includes("@") ? "Email tidak valid" : ""}
							/>
						</Grid>
						<Grid item xs={12}>
							<TextField
								variant="outlined"
								fullWidth
								id="phone"
								label="Telepon"
								name="phone"
								value={company.phone}
								onChange={handleChangeInput}
								autoComplete="tel"
							/>
						</Grid>
						<Grid item xs={12}>
							<FormControl fullWidth variant="outlined" required>
								<InputLabel>Paket</InputLabel>
								<Select
									id="planId"
									name="planId"
									value={company.planId}
									onChange={handleChangeInput}
									label="Paket"
								>
									{plans.map(plan => (
										<MenuItem key={plan.id} value={plan.id}>
											{plan.name}
										</MenuItem>
									))}
								</Select>
							</FormControl>
						</Grid>
						<Grid item xs={12}>
							<FormControl fullWidth variant="outlined">
								<InputLabel>Status</InputLabel>
								<Select
									id="status"
									name="status"
									value={company.status}
									onChange={handleChangeInput}
									label="Status"
								>
									<MenuItem value={true}>Aktif</MenuItem>
									<MenuItem value={false}>Tidak Aktif</MenuItem>
								</Select>
							</FormControl>
						</Grid>
						<Grid item xs={12}>
							<FormControl fullWidth variant="outlined">
								<InputLabel>Kampanye</InputLabel>
								<Select
									id="campaignsEnabled"
									name="campaignsEnabled"
									value={company.campaignsEnabled}
									onChange={handleChangeInput}
									label="Kampanye"
								>
									<MenuItem value={true}>Aktif</MenuItem>
									<MenuItem value={false}>Tidak Aktif</MenuItem>
								</Select>
							</FormControl>
						</Grid>
					</Grid>
					<Button
						type="submit"
						fullWidth
						variant="contained"
						color="primary"
						className={classes.submit}
						disabled={loading || !company.name || !company.email || !company.planId}
					>
						{loading ? "Menyimpan..." : "Simpan"}
					</Button>
				</form>
			</div>
		</Container>
	);
};

export default FormCompany;
