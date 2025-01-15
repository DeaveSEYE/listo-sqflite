const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotificationOnDatabaseChange = functions.firestore
  .document("users/{docId}") // Remplacez "your_collection" par le chemin de votre collection
  .onWrite(async (change, context) => {
    const dataAfter = change.after.data(); // Données après le changement

    if (!dataAfter) {
      // Si le document est supprimé, ne rien faire
      return null;
    }

    const message = {
      notification: {
        title: "Base de données mise à jour",
        body: `Un changement a été détecté pour ${dataAfter.someField}`, // Ajoutez un champ de description
      },
      topic: "database-updates", // Diffusez à un groupe d'utilisateurs
    };

    // Envoyer la notification via FCM
    await admin.messaging().send(message);
    console.log("Notification envoyée avec succès.");
    return null;
  });
