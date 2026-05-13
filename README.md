# Kimia-Farma-Big-Data-Analytics

# Credits / Acknowledgment
- [rakamin.com](https://app.rakamin.com/)
- [kimia farma](https://www.kimiafarma.co.id/)

Analisis kinerja bisnis Kimia Farma Tahun 2020-2023Berikut ini adalah task yang harus lakukan:

Importing Dataset to BigQuery Pada proyek ini ditugaskan untuk mengimpor dataset yang telah disediakan:

kf_final_transaction.csv (link),
kf_inventory.csv (link),
kf_kantor_cabang.csv (link),
kf_product.csv (link). 


mengimport keempat dataset tersebut untuk menjadi tabel pada BigQuery, nama tablenya merupakan nama dari dataset, namun tanpa ".csv"


Buat tabel analisa Pada proyek ini, diminta untuk membuat table analisa berdasarkan hasil aggregasi dari ke-empat table yang sudah diimport sebelumnya. Berikut ini adalah kolom-kolom yang mandatory pada tabel tersebut: 
- transaction_id : kode id transaksi, 
- date : tanggal transaksi dilakukan, 
- branch_id : kode id cabang Kimia Farma, 
- branch_name : nama cabang Kimia Farma, 
- kota : kota cabang Kimia Farma, 
- provinsi : provinsi cabang Kimia Farma, rating_cabang : penilaian konsumen terhadap cabang Kimia Farma 
- customer_name : Nama customer yang melakukan transaksi, 
- product_id : kode product obat, 
- product_name : nama obat, 
- actual_price : harga obat, 
- discount_percentage : Persentase diskon yang diberikan pada obat, 
- persentase_gross_laba : Persentase laba yang seharusnya diterima dari obat dengan ketentuan berikut: 

- Harga <= Rp 50.000 -> laba 10% 
- Harga > Rp 50.000 - 100.000 -> laba 15% 
- Harga > Rp 100.000 - 300.000 -> laba 20% 
- Harga > Rp 300.000 - 500.000 -> laba 25% 
- Harga > Rp 500.000 -> laba 30%, 

- nett_sales : harga setelah diskon, 
- nett_profit : keuntungan yang diperoleh Kimia Farma, 
- rating_transaksi : penilaian konsumen terhadap transaksi yang dilakukan.

diharapkan dapat
- Memahami konsep Data Warehouse
- Mampu melakukan proses pembuatan Data Mart
- Mampu melakukan Querying
- Mampu melakukan Data Analysis
- Mampu melakukan Data Visualization
- Mampu melakukan Data Storytelling
- Mampu melakukan Dashboarding
