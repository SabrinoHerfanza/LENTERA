/**
 * ============================================================
 * LENTERA
 * Create / Update Firebase Authentication accounts for students
 * ============================================================
 *
 * INPUT:
 *   lentera_firebase_users.json
 *
 * PASSWORD DEFAULT:
 *   123456
 *
 * FUNGSI:
 *   1. Membuat akun Firebase Authentication siswa
 *   2. Jika akun sudah ada -> password di-reset menjadi 123456
 *   3. Menyimpan profil siswa ke Firebase Realtime Database
 *   4. Menyimpan authUid ke database
 *   5. Menetapkan role = siswa
 *
 * FILE YANG DIBUTUHKAN:
 *
 *   lentera_auth_setup/
 *   ├── create_lentera_users.js
 *   ├── lentera_firebase_users.json
 *   └── serviceAccountKey.json
 *
 * JALANKAN:
 *
 *   node create_lentera_users.js
 *
 * ============================================================
 */

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

// ============================================================
// KONFIGURASI
// ============================================================

const DATA_FILE =
  process.env.LENTERA_DATA_FILE ||
  path.resolve(
    __dirname,
    'lentera_firebase_users.json'
  );

const SERVICE_ACCOUNT_FILE =
  process.env.FIREBASE_SERVICE_ACCOUNT ||
  path.resolve(
    __dirname,
    'serviceAccountKey.json'
  );

// Password default semua siswa
const DEFAULT_PASSWORD =
  process.env.LENTERA_DEFAULT_PASSWORD ||
  '123456';

// Firebase Realtime Database
const DATABASE_URL =
  'https://lentera-21607-default-rtdb.asia-southeast1.firebasedatabase.app';

// ============================================================
// CEK FILE JSON DATA
// ============================================================

if (!fs.existsSync(DATA_FILE)) {
  console.error('');
  console.error(
    '❌ Data JSON tidak ditemukan:'
  );
  console.error(DATA_FILE);
  console.error('');
  process.exit(1);
}

// ============================================================
// CEK SERVICE ACCOUNT
// ============================================================

if (!fs.existsSync(SERVICE_ACCOUNT_FILE)) {
  console.error('');
  console.error(
    '❌ Service account tidak ditemukan:'
  );
  console.error(SERVICE_ACCOUNT_FILE);
  console.error('');
  console.error(
    'Download service account JSON dari:'
  );
  console.error(
    'Firebase Console > Project settings > Service accounts'
  );
  console.error('');
  process.exit(1);
}

// ============================================================
// LOAD SERVICE ACCOUNT
// ============================================================

let serviceAccount;

try {
  serviceAccount =
    require(SERVICE_ACCOUNT_FILE);
} catch (error) {
  console.error('');
  console.error(
    '❌ Gagal membaca serviceAccountKey.json'
  );
  console.error(error.message);
  console.error('');
  process.exit(1);
}

// ============================================================
// INITIALIZE FIREBASE ADMIN
// ============================================================

admin.initializeApp({
  credential:
    admin.credential.cert(serviceAccount),

  databaseURL: DATABASE_URL,
});

// ============================================================
// FIREBASE SERVICE
// ============================================================

const db = admin.database();
const auth = admin.auth();

// ============================================================
// LOAD DATA JSON
// ============================================================

let data;

try {
  const jsonText =
    fs.readFileSync(
      DATA_FILE,
      'utf8'
    );

  data = JSON.parse(jsonText);
} catch (error) {
  console.error('');
  console.error(
    '❌ Gagal membaca lentera_firebase_users.json'
  );
  console.error(error.message);
  console.error('');
  process.exit(1);
}

// ============================================================
// AMBIL USERS
// ============================================================

const students =
  data.users || {};

const entries =
  Object.entries(students);

// ============================================================
// FUNGSI CREATE / UPDATE USER
// ============================================================

async function createOrUpdateUser(
  student
) {
  try {
    // --------------------------------------------------------
    // COBA BUAT AKUN BARU
    // --------------------------------------------------------

    const user =
      await auth.createUser({
        email: student.email,
        password: DEFAULT_PASSWORD,
        displayName: student.nama,
        disabled: false,
      });

    return {
      user,
      created: true,
      updated: false,
    };
  } catch (error) {
    // --------------------------------------------------------
    // EMAIL SUDAH TERDAFTAR
    // --------------------------------------------------------

    if (
      error.code ===
      'auth/email-already-exists'
    ) {
      // Ambil akun yang sudah ada
      const user =
        await auth.getUserByEmail(
          student.email
        );

      // ------------------------------------------------------
      // RESET PASSWORD AKUN LAMA
      // ------------------------------------------------------

      const updatedUser =
        await auth.updateUser(
          user.uid,
          {
            password:
              DEFAULT_PASSWORD,

            displayName:
              student.nama,

            disabled: false,
          }
        );

      return {
        user: updatedUser,
        created: false,
        updated: true,
      };
    }

    // --------------------------------------------------------
    // ERROR LAIN
    // --------------------------------------------------------

    throw error;
  }
}

// ============================================================
// MAIN
// ============================================================

async function main() {
  console.log('');
  console.log(
    '============================================================'
  );
  console.log(
    ' LENTERA - Firebase Authentication Setup'
  );
  console.log(
    '============================================================'
  );
  console.log('');

  console.log(
    `Data JSON      : ${DATA_FILE}`
  );

  console.log(
    `Service Account: ${SERVICE_ACCOUNT_FILE}`
  );

  console.log(
    `Database       : ${DATABASE_URL}`
  );

  console.log(
    `Password awal  : ${DEFAULT_PASSWORD}`
  );

  console.log('');

  console.log(
    `Total siswa ditemukan: ${entries.length}`
  );

  console.log('');

  // ==========================================================
  // COUNTER
  // ==========================================================

  let created = 0;
  let updated = 0;
  let failed = 0;

  // ==========================================================
  // PROSES SISWA SATU PER SATU
  // ==========================================================

  for (
    const [nis, student]
    of entries
  ) {
    try {
      // ------------------------------------------------------
      // VALIDASI DATA
      // ------------------------------------------------------

      if (!student) {
        throw new Error(
          'Data siswa kosong'
        );
      }

      if (
        !student.email ||
        !student.nama
      ) {
        throw new Error(
          'Email atau nama siswa tidak tersedia'
        );
      }

      // ------------------------------------------------------
      // CREATE / UPDATE AUTH
      // ------------------------------------------------------

      const result =
        await createOrUpdateUser(
          student
        );

      const user =
        result.user;

      // ------------------------------------------------------
      // COUNTER
      // ------------------------------------------------------

      if (result.created) {
        created++;
      }

      if (result.updated) {
        updated++;
      }

      // ------------------------------------------------------
      // SIMPAN KE REALTIME DATABASE
      //
      // Struktur:
      //
      // users
      //   └── NIS
      //        ├── nama
      //        ├── email
      //        ├── nis
      //        ├── authUid
      //        └── role
      //
      // ------------------------------------------------------

      await db
        .ref(`users/${nis}`)
        .update({
          ...student,

          nis: nis,

          authUid: user.uid,

          role: 'siswa',
        });

      // ------------------------------------------------------
      // LOG
      // ------------------------------------------------------

      if (result.created) {
        console.log(
          `CREATE ${nis} | ${student.nama} | ${student.email} | ${user.uid}`
        );
      } else {
        console.log(
          `UPDATE ${nis} | ${student.nama} | ${student.email} | ${user.uid}`
        );
      }

    } catch (error) {
      // ------------------------------------------------------
      // ERROR SISWA
      // ------------------------------------------------------

      failed++;

      console.error(
        `ERR ${nis} | ${
          student?.nama || ''
        } | ${
          error.code ||
          error.message
        }`
      );
    }
  }

  // ==========================================================
  // HASIL AKHIR
  // ==========================================================

  console.log('');

  console.log(
    '============================================================'
  );

  console.log(
    ' Selesai.'
  );

  console.log(
    '============================================================'
  );

  console.log(
    `Dibuat        : ${created}`
  );

  console.log(
    `Password reset: ${updated}`
  );

  console.log(
    `Gagal         : ${failed}`
  );

  console.log(
    `Total diproses: ${entries.length}`
  );

  console.log(
    '============================================================'
  );

  console.log('');

  console.log(
    'Password semua akun yang dibuat / di-update:'
  );

  console.log(
    DEFAULT_PASSWORD
  );

  console.log('');
}

// ============================================================
// JALANKAN PROGRAM
// ============================================================

main()
  .then(async () => {
    try {
      await admin.app().delete();
    } catch (_) {}

    process.exit(0);
  })
  .catch(async (error) => {
    console.error('');
    console.error(
      '❌ ERROR FATAL'
    );
    console.error(error);
    console.error('');

    try {
      await admin.app().delete();
    } catch (_) {}

    process.exit(1);
  });