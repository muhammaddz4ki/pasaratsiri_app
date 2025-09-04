import {onDocumentCreated, onDocumentDeleted} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

// Inisialisasi Firebase Admin SDK
initializeApp();

/**
 * Trigger V2 yang berjalan SETIAP KALI DOKUMEN BARU DIBUAT
 * di dalam sub-koleksi 'registrants'.
 */
export const onRegistrantCreate = onDocumentCreated(
  // Opsi ditempatkan di dalam objek, termasuk path dokumen dan region
  {
    document: "trainings/{trainingId}/registrants/{registrantId}",
    region: "asia-southeast2",
  },
  // Event handler dengan parameter 'event' yang sudah memiliki tipe data
  async (event) => {
    // 1. Dapatkan ID pelatihan dari parameter event
    const trainingId = event.params.trainingId;
    console.log(`Pendaftar baru terdeteksi untuk pelatihan ID: ${trainingId}`);

    // 2. Buat referensi ke dokumen training induknya
    const trainingRef = getFirestore().collection("trainings").doc(trainingId);

    // 3. Update field 'currentParticipants' dengan menambah 1
    return trainingRef.update({
      currentParticipants: admin.firestore.FieldValue.increment(1),
    });
  },
);

/**
 * Trigger V2 yang berjalan SETIAP KALI DOKUMEN DIHAPUS
 * dari sub-koleksi 'registrants'.
 */
export const onRegistrantDelete = onDocumentDeleted(
  {
    document: "trainings/{trainingId}/registrants/{registrantId}",
    region: "asia-southeast2",
  },
  async (event) => {
    // 1. Dapatkan ID pelatihan dari parameter event
    const trainingId = event.params.trainingId;
    console.log(`Pendaftar dihapus dari pelatihan ID: ${trainingId}`);

    // 2. Buat referensi ke dokumen training induknya
    const trainingRef = getFirestore().collection("trainings").doc(trainingId);

    // 3. Update field 'currentParticipants' dengan mengurangi 1
    return trainingRef.update({
      currentParticipants: admin.firestore.FieldValue.increment(-1),
    });
  },
);
