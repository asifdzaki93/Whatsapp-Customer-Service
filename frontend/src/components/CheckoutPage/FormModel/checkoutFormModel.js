export default {
  formId: 'checkoutForm',
  formField: {
    firstName: {
      name: 'firstName',
      label: 'Nama Lengkap*',
      requiredErrorMsg: 'Nama lengkap wajib diisi'
    },
    lastName: {
      name: 'lastName',
      label: 'Nama Belakang*',
      requiredErrorMsg: 'Nama belakang wajib diisi'
    },
    address1: {
      name: 'address2',
      label: 'Alamat*',
      requiredErrorMsg: 'Alamat wajib diisi'
    },
    city: {
      name: 'city',
      label: 'Kota*',
      requiredErrorMsg: 'Kota wajib diisi'
    },
    state: {
      name: 'state',
      label: 'Provinsi*',
      requiredErrorMsg: 'Provinsi wajib diisi'
    },
    zipcode: {
      name: 'zipcode',
      label: 'Kode Pos*',
      requiredErrorMsg: 'Kode pos wajib diisi',
      invalidErrorMsg: 'Format kode pos tidak valid'
    },
    country: {
      name: 'country',
      label: 'Negara*',
      requiredErrorMsg: 'Negara wajib diisi'
    },
    useAddressForPaymentDetails: {
      name: 'useAddressForPaymentDetails',
      label: 'Gunakan alamat ini untuk detail pembayaran'
    },
    invoiceId: {
      name: 'invoiceId',
      label: 'Gunakan ID Faktur ini'
    },
    nameOnCard: {
      name: 'nameOnCard',
      label: 'Nama di Kartu*',
      requiredErrorMsg: 'Nama di kartu wajib diisi'
    },
    cardNumber: {
      name: 'cardNumber',
      label: 'Nomor Kartu*',
      requiredErrorMsg: 'Nomor kartu wajib diisi',
      invalidErrorMsg: 'Nomor kartu tidak valid (contoh: 4111111111111)'
    },
    expiryDate: {
      name: 'expiryDate',
      label: 'Tanggal Kadaluarsa*',
      requiredErrorMsg: 'Tanggal kadaluarsa wajib diisi',
      invalidErrorMsg: 'Tanggal kadaluarsa tidak valid'
    },
    cvv: {
      name: 'cvv',
      label: 'CVV*',
      requiredErrorMsg: 'CVV wajib diisi',
      invalidErrorMsg: 'CVV tidak valid (contoh: 357)'
    }
  }
};
