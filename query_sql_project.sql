-- File   : query_sql_project.sql
-- Author : Suyanto
-- Date   : 27-04-2026


-- Tabel diatas merupakan hasil agregasi dari keempat tabel yang dibuat sebelumnya dan 
-- berikut adalah syntax BigQuery untuk membuat table ini:
-- Query create tabel analisa
CREATE OR REPLACE TABLE `rakamin-kf-analytics-493319.kimia_farma.kf_analisa` AS
WITH hitung_laba AS (
  SELECT
    t.transaction_id,
    t.date,
    t.branch_id,
    c.branch_name,
    c.kota,
    c.provinsi,
    c.rating AS rating_cabang,
    t.customer_name,
    t.product_id,
    p.product_name,
    t.price AS actual_price,
    t.discount_percentage,
    t.rating AS rating_transaksi,

    CASE
      WHEN t.price <= 50000 THEN 0.10
      WHEN t.price > 50000 AND t.price <= 100000 THEN 0.15
      WHEN t.price > 100000 AND t.price <= 300000 THEN 0.20
      WHEN t.price > 300000 AND t.price <= 500000 THEN 0.25
      ELSE 0.30 
    END AS persentase_gross_laba

  FROM `rakamin-kf-analytics-493319.kimia_farma.kf_final_transaction` t
  JOIN `rakamin-kf-analytics-493319.kimia_farma.kf_product` p
    ON t.product_id = p.product_id
  JOIN `rakamin-kf-analytics-493319.kimia_farma.kf_kantor_cabang` c
    ON t.branch_id = c.branch_id
)


SELECT
  *,
  actual_price * (1 - SAFE_DIVIDE(discount_percentage, 100)) AS nett_sales,
  (actual_price * (1 - SAFE_DIVIDE(discount_percentage, 100))) * persentase_gross_laba AS nett_profit
FROM hitung_laba;



SELECT
  COUNT(*) AS total_baris
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_final_transaction`



-- membandingkan jumlah baris antara tabel sumber (tabel_transaksi) --dengan tabel hasil yang baru saja kita buat (Analisa)

SELECT 
  'kf_final_transaction' AS nama_tabel, COUNT(*) AS jumlah_baris 
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_final_transaction`

UNION ALL

SELECT 
  'kf_analisa' AS nama_tabel, COUNT(*) AS jumlah_baris 
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_analisa`;



-- Cek Apakah Ada Nilai NULL pada Kolom Penting
-- Kadang ada data yang masuk tanpa harga atau tanpa ID. Query ini memastikan semua kolom krusial terisi:
-- SQL

SELECT 
  countif(transaction_id IS NULL) AS missing_id,
  countif(actual_price IS NULL OR actual_price = 0) AS invalid_price,
  countif(nett_profit IS NULL) AS missing_profit
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_analisa`;


-- Cek Statistik Ringkas (Min, Max, Avg)
-- Untuk memastikan tidak ada angka "ajaib" (misalnya profit minus yang tidak masuk akal atau harga yang terlalu tinggi):
-- SQL

SELECT 
  MIN(actual_price) AS harga_termurah,
  MAX(actual_price) AS harga_termahal,
  AVG(nett_profit) AS rata_rata_profit,
  SUM(nett_profit) AS total_profit_seluruhnya
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_analisa`;


-- Lihat 10 Cabang dengan Profit Tertinggi
-- Ini adalah contoh analisis sederhana yang bisa langsung Anda gunakan untuk laporan:

SELECT 
  branch_name, 
  kota, 
  SUM(nett_profit) AS total_laba
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_analisa`
GROUP BY 1, 2
ORDER BY total_laba DESC
LIMIT 10;

-- Cek Duplikasi Transaksi
-- Terkadang dalam sistem database, satu transaksi bisa terinput dua kali karena kesalahan sistem.

SELECT 
  transaction_id, 
  COUNT(*) as jumlah_duplikat
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_analisa`
GROUP BY 1
HAVING jumlah_duplikat > 1;


-- Cek Konsistensi Nama (Standarisasi)
-- Cek apakah ada nama kota atau provinsi yang tertulis berbeda padahal maksudnya sama (misal: "Jakarta" vs "DKI Jakarta").

SELECT 
  provinsi, 
  COUNT(DISTINCT kota) as jumlah_kota
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_analisa`
GROUP BY 1;

-- cek DISTINCT kota untuk melihat apakah ada typo seperti "Bks" vs "Bekasi".


SELECT 
  provinsi, 
  kota, 
  COUNT(*) as jumlah_transaksi
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_analisa`
WHERE provinsi IN ('DKI Jakarta', 'Jawa Barat', 'Banten') -- Tambahkan provinsi lain jika perlu
GROUP BY 1, 2
ORDER BY 1, 2;

-- hasil query, datanya terlihat sangat bersih. Nama-nama kota seperti "Cikampek", "Karawang", "Medan", hingga "Deli Serdang" sudah menggunakan format Proper Case (huruf besar di awal) dan tidak terlihat adanya duplikasi nama kota yang disebabkan oleh perbedaan spasi atau singkatan.
-- memastikan bahwa kolom-kolom hasil perhitungan (nett_sales dan nett_profit) tidak memiliki nilai yang mustahil. Jalankan query ini untuk mendeteksi anomali:

SELECT 
  COUNTIF(actual_price <= 0) AS harga_tidak_valid,
  COUNTIF(discount_percentage > 100) AS diskon_over_100,
  COUNTIF(nett_sales <= 0) AS sales_nol_atau_negatif,
  COUNTIF(nett_profit <= 0) AS profit_nol_atau_negatif,
  COUNTIF(rating_transaksi IS NULL) AS rating_kosong
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_analisa`;


-- Langkah Cleaning Tambahan: Cek "Outliers" Kadang ada data "sampah" berupa transaksi dengan nilai yang tidak masuk akal (terlalu besar). Mari kita cek 5 transaksi dengan profit tertinggi dan terendah:

(SELECT 'Profit Tertinggi' AS tipe, transaction_id, nett_profit 
 FROM `rakamin-kf-analytics-493319.kimia_farma.kf_analisa` 
 ORDER BY nett_profit DESC LIMIT 5)
UNION ALL
(SELECT 'Profit Terendah' AS tipe, transaction_id, nett_profit 
 FROM `rakamin-kf-analytics-493319.kimia_farma.kf_analisa` 
 ORDER BY nett_profit ASC LIMIT 5);

-- Analisis Profitabilitas per Provinsi Melihat provinsi mana yang menyumbang keuntungan bersih paling besar.

SELECT 
  provinsi, 
  ROUND(SUM(nett_sales), 2) AS total_penjualan,
  ROUND(SUM(nett_profit), 2) AS total_keuntungan,
  ROUND(AVG(rating_transaksi), 2) AS rata_rata_kepuasan
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_analisa`
GROUP BY 1
ORDER BY total_keuntungan DESC;


-- Analisis Performa Produk (The "Winner" Products) Sekarang Anda bisa melihat produk mana yang paling banyak menyumbang laba. Bukan hanya yang paling laris (kuantitas), tapi yang paling menguntungkan (profit).

SELECT 
  product_name,
  COUNT(transaction_id) AS jumlah_terjual,
  ROUND(SUM(nett_sales), 2) AS total_sales,
  ROUND(SUM(nett_profit), 2) AS total_profit
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_analisa`
GROUP BY 1
ORDER BY total_profit DESC
LIMIT 10;


-- profit dan rata-rata rating transaksi yang besar dan jelas.


SELECT 
  provinsi, 
  ROUND(SUM(nett_sales), 2) AS total_penjualan,
  ROUND(SUM(nett_profit), 2) AS total_keuntungan,
  ROUND(AVG(rating_transaksi), 2) AS rata_rata_kepuasan
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_analisa`
GROUP BY 1
ORDER BY total_keuntungan DESC;


--query untuk melihat perbandingan antara stok yang ada (opname_stock) dengan jumlah produk yang terjual:

SELECT 
  inv.branch_id,
  c.branch_name,
  inv.product_id,
  inv.product_name,
  inv.opname_stock AS stok_saat_ini,
  -- Menghitung total item yang terjual dari tabel transaksi
  SUM(CASE WHEN tr.transaction_id IS NOT NULL THEN 1 ELSE 0 END) AS total_unit_terjual,
  -- Menghitung total nilai penjualan (jika diperlukan)
  ROUND(SUM(tr.price * (1 - SAFE_DIVIDE(tr.discount_percentage, 100))), 2) AS total_sales_amount
FROM `rakamin-kf-analytics-493319.kimia_farma.kf_inventory` AS inv
-- Join ke tabel cabang untuk mendapatkan nama cabang
LEFT JOIN `rakamin-kf-analytics-493319.kimia_farma.kf_kantor_cabang` AS c
  ON inv.branch_id = c.branch_id
-- Join ke tabel transaksi menggunakan dua kunci: branch_id dan product_id
LEFT JOIN `rakamin-kf-analytics-493319.kimia_farma.kf_final_transaction` AS tr
  ON inv.branch_id = tr.branch_id 
  AND inv.product_id = tr.product_id
GROUP BY 1, 2, 3, 4, 5
ORDER BY total_unit_terjual DESC LIMIT 10;


