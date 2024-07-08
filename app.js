const express = require("express");
const mysql = require("mysql2");
const bodyParser = require("body-parser");
const cors = require("cors");

const app = express();
const port = 3000;
app.use(bodyParser.json());
app.use(cors());

app.get("/", (req, res) => {
  res.send("Hello, World!");
});

const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "DBINVENTORI",
});

db.connect((err) => {
  if (err) {
    console.error("error connecting: " + err.stack);
    return;
  }
  console.log("connected as id " + db.threadId);
});

app.get("/api/barang", (req, res) => {
  const query = `
      SELECT 
        b.KD_BARANG,
        b.NAMA_BRG,
        b.HARGA,
        bs.DISC,
        pd.QTY,
        p.TGL_TRANS,
        s.KD_SUP,
        s.NAMA_SUP
      FROM barang b
      LEFT JOIN barang_supplier bs ON b.KD_BARANG = bs.KD_BARANG
      LEFT JOIN po_detail pd ON b.KD_BARANG = pd.KD_BARANG
      LEFT JOIN po p ON pd.KD_TRANS = p.KT_TRANS
      LEFT JOIN supplier s ON p.KD_SUP = s.KD_SUP;
    `;

  db.query(query, (err, results) => {
    if (err) {
      console.error("Error fetching data:", err);
      res.status(500).send("Error fetching data");
      return;
    }

    // Transform results into a structured format
    const transformedResults = results.reduce((acc, row) => {
      // Create or get existing entry for the item
      if (!acc[row.KD_BARANG]) {
        acc[row.KD_BARANG] = {
          KD_BARANG: row.KD_BARANG,
          NAMA_BRG: row.NAMA_BRG,
          HARGA: row.HARGA,
          DISC: row.DISC,
          TRANSACTIONS: [],
          SUPPLIERS: [],
        };
      }

      // Add transaction information
      if (row.QTY !== null && row.TGL_TRANS) {
        acc[row.KD_BARANG].TRANSACTIONS.push({
          QTY: row.QTY,
          TGL_TRANS: row.TGL_TRANS,
          SUPPLIER: {
            KD_SUP: row.KD_SUP,
            NAMA_SUP: row.NAMA_SUP,
          },
        });
      }

      // Add supplier information if exists
      if (row.DISC !== null && !acc[row.KD_BARANG].SUPPLIERS.some((s) => s.KD_SUP === row.KD_SUP)) {
        acc[row.KD_BARANG].SUPPLIERS.push({
          KD_SUP: row.KD_SUP,
          NAMA_SUP: row.NAMA_SUP,
          DISC: row.DISC,
        });
      }

      return acc;
    }, {});

    // Convert object to array
    const resultArray = Object.values(transformedResults);

    res.json(resultArray);
  });
});

app.get("/api/users", (req, res) => {
  db.query("SELECT * FROM tbl_User", (err, results) => {
    if (err) {
      res.status(500).json({ error: "Error fetching data" });
      return;
    }
    res.json(results);
  });
});

app.post("/api/login", (req, res) => {
  const { userId, password } = req.body;

  if (!userId || !password) {
    return res.status(400).json({ error: "UserId and Password are required" });
  }

  const query = "SELECT * FROM tbl_User WHERE UserId = ? AND Password = ?";
  db.query(query, [userId, password], (err, results) => {
    if (err) {
      console.error("Error querying the database: " + err.stack);
      return res.status(500).json({ error: "Error querying the database" });
    }
    if (results.length > 0) {
      res.json({ success: true, message: "Login successful" });
    } else {
      res.status(401).json({ success: false, message: "Invalid UserId or Password" });
    }
  });
});

app.get("/api/supplier/:kodeSupplier", (req, res) => {
  const kodeSupplier = req.params.kodeSupplier;

  const query = "SELECT * FROM supplier WHERE KD_SUP = ?";

  db.query(query, [kodeSupplier], (err, results) => {
    if (err) {
      console.error("Error fetching supplier:", err);
      return res.status(500).send("Error fetching supplier");
    }

    if (results.length === 0) {
      return res.status(404).json({ message: "Supplier not found" });
    }

    res.json(results[0]);
  });
});

app.get("/api/nextId", (req, res) => {
  const query = "SELECT KT_TRANS FROM po ORDER BY KT_TRANS DESC LIMIT 1";

  db.query(query, (err, results) => {
    if (err) {
      console.error("Error fetching last transaction code:", err);
      res.status(500).send("Error fetching last transaction code");
      return;
    }

    let lastCode = results[0] ? results[0].KT_TRANS : "T0000";
    let newCodeNumber = parseInt(lastCode.slice(1), 10) + 1;
    let newCode = "T" + newCodeNumber.toString().padStart(4, "0");

    res.json({ newCode });
  });
});

app.get("/api/supplier/:kodeSupplier", (req, res) => {
  const kodeSupplier = req.params.kodeSupplier;

  const query = "SELECT * FROM supplier WHERE KD_SUP = ?";

  db.query(query, [kodeSupplier], (err, results) => {
    if (err) {
      console.error("Error fetching supplier:", err);
      return res.status(500).send("Error fetching supplier");
    }

    if (results.length === 0) {
      return res.status(404).json({ message: "Supplier not found" });
    }

    res.json(results[0]);
  });
});

app.post("/api/po", (req, res) => {
  const { kodeTransaksi, totalItem, discount, totalHarga, tglTransaksi, kodeSupplier } = req.body;

  const query = `
      INSERT INTO po (KD_TRANS, TOTAL_ITEM, DISCOUNT, TOTAL_HARGA, TGL_TRANS, KD_SUP)
      VALUES (?, ?, ?, ?, ?, ?)
    `;

  db.query(query, [kodeTransaksi, totalItem, discount, totalHarga, tglTransaksi, kodeSupplier], (err, results) => {
    if (err) {
      console.error("Error inserting transaction:", err);
      res.status(500).send("Error inserting transaction");
      return;
    }
    res.status(201).send({ id: results.insertId });
  });
});

app.post("/api/podetail", (req, res) => {
  req.body.forEach((item) => {
    const { KD_TRANS, KD_BARANG, QTY, HARGA, DISC, NAMA_BRG } = item;
    console.log(KD_TRANS, KD_BARANG, QTY, HARGA, DISC, NAMA_BRG, "asd");

    // Validasi input
    if (!KD_TRANS || !KD_BARANG || !QTY || !HARGA || !NAMA_BRG) {
      return res.status(400).send("Missing required fielfds");
    }
    const query = `
  INSERT INTO po_detail (KD_TRANS, KD_BARANG, QTY, HARGA, DISC)
  VALUES (?, ?, ?, ?, ?)
`;
  });

  db.query(query, [KD_TRANS, KD_BARANG, QTY, HARGA, DISC], (err) => {
    if (err) {
      console.error("Error inserting PO details:", err);
      return res.status(500).send("Error inserting PO details");
    }
    res.send("PO details inserted successfully");
  });
});

app.delete("/api/po/:kodeTransaksi", (req, res) => {
  const { kodeTransaksi } = req.params;

  const query = `
      DELETE FROM po
      WHERE kode_transaksi = ?
    `;

  db.query(query, [kodeTransaksi], (err) => {
    if (err) {
      console.error("Error deleting transaction:", err);
      res.status(500).send("Error deleting transaction");
      return;
    }

    // Optionally delete related PO details
    db.query("DELETE FROM po_detail WHERE kode_transaksi = ?", [kodeTransaksi], (err) => {
      if (err) {
        console.error("Error deleting PO details:", err);
        res.status(500).send("Error deleting PO details");
        return;
      }

      res.send("Transaction and related details deleted");
    });
  });
});

app.put("/api/po", (req, res) => {
  const { kodeTransaksi, totalItem, discount, totalHarga, tglTransaksi, kodeSupplier } = req.body;

  const query = `
      UPDATE po
      SET TOTAL_ITEM = ?, DISCOUNT = ?, TOTAL_HARGA = ?, TGL_TRANS = ?, KD_SUP = ?
      WHERE KT_TRANS = ?
    `;

  db.query(query, [totalItem, discount, totalHarga, tglTransaksi, kodeSupplier, kodeTransaksi], (err) => {
    if (err) {
      console.error("Error updating transaction:", err);
      res.status(500).send("Error updating transaction");
      return;
    }
    res.send("Transaction updated");
  });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});
