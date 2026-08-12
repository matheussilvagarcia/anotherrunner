// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get steps => 'PAS';

  @override
  String get startRun => 'Démarrer la course';

  @override
  String get syncHealthConnect => 'Synchroniser Health Connect';

  @override
  String get todayYouTook => 'aujourd\'hui vous avez marché';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get credits => 'Crédits';

  @override
  String get language => 'Langue';

  @override
  String get lastSyncOn => 'Dernière synchronisation cloud le';

  @override
  String get unlockPremium => 'Débloquer les Graphiques Premium';

  @override
  String get premiumDesc =>
      'Accédez à des moyennes hebdomadaires et mensuelles détaillées. Suivez visuellement vos progrès en matière de calories, de pas, de distance et de temps de course pour atteindre vos objectifs plus rapidement !';

  @override
  String get buyFor => 'Acheter pour';

  @override
  String get buyNow => 'Acheter maintenant';

  @override
  String get maybeLater => 'Peut-être plus tard';

  @override
  String get syncSuccess => 'Données synchronisées dans le cloud avec succès !';

  @override
  String get hcSyncSuccess =>
      'Données synchronisées ! Courses ajoutées à l\'historique.';

  @override
  String get hcNoData => 'Aucune donnée de santé trouvée pour aujourd\'hui.';

  @override
  String get hcPermissionDenied =>
      'Autorisation refusée pour accéder aux données de santé.';

  @override
  String get capturedByHealthConnect => 'Capturé par Health Connect';

  @override
  String get activityAverages => 'Moyennes d\'activité';

  @override
  String get last7Days => 'Les 7 derniers jours';

  @override
  String get monthlyAverages => 'Moyennes mensuelles';

  @override
  String get chartSteps => 'Pas';

  @override
  String get chartCalories => 'Calories (kcal)';

  @override
  String get chartDistance => 'Distance (km)';

  @override
  String get chartDuration => 'Durée (min)';

  @override
  String get locationPermissionRequired =>
      'L\'autorisation de localisation est nécessaire pour suivre votre course.';

  @override
  String get runHistory => 'Historique des courses';

  @override
  String get authenticationRequired => 'Authentification requise';

  @override
  String get noRunsRecorded => 'Aucune course enregistrée pour le moment.';

  @override
  String shareRunMessage(String date) {
    return 'Découvrez ma course sur MovePass le $date !';
  }

  @override
  String get dailyActivity => 'Activité quotidienne';

  @override
  String get noDailyRecords => 'Aucun enregistrement quotidien pour le moment.';

  @override
  String get unknownDate => 'Inconnu';

  @override
  String get currentRun => 'Course actuelle';

  @override
  String get timeLabel => 'TEMPS';

  @override
  String get paceLabel => 'ALLURE';

  @override
  String get distanceLabel => 'DISTANCE';

  @override
  String get caloriesLabel => 'CALORIES';

  @override
  String get runningTracker => 'Suivi de course';

  @override
  String get activeRunMetrics => 'Métriques de la course active';

  @override
  String get runInProgress => 'Course en cours';

  @override
  String get starting => 'Démarrage...';

  @override
  String notificationBody(String time, String dist, String pace) {
    return 'Temps : $time  |  Dist : $dist km  |  Allure : $pace/km';
  }

  @override
  String get developedBy => 'Développé par';

  @override
  String get contactMe => 'Me contacter';

  @override
  String get githubProfile => 'Profil GitHub';

  @override
  String get visitPortfolio => 'Visitez mon Portfolio';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get passwordsNotMatch => 'Les mots de passe ne correspondent pas !';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit comporter au moins 6 caractères';

  @override
  String get errorSendingOtp =>
      'Erreur lors de l\'envoi du code de vérification.';

  @override
  String get confirmEmailTitle => 'Confirmez votre e-mail';

  @override
  String otpSentMessage(String email) {
    return 'Nous avons envoyé un code à 6 chiffres à $email.';
  }

  @override
  String get otpCodeLabel => 'Code OTP';

  @override
  String get cancelBtn => 'Annuler';

  @override
  String get confirmBtn => 'Confirmer';

  @override
  String get invalidOtp => 'Code invalide.';

  @override
  String get welcomeTo => 'Bienvenue sur :';

  @override
  String get chooseLoginMethod => 'Choisissez votre méthode de connexion';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get createAccountBtn => 'Créer un compte';

  @override
  String get signInBtn => 'Se connecter';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? Se connecter';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ? Créer un compte';

  @override
  String get signInWithGoogleBtn => 'Se connecter avec Google';

  @override
  String get emailInUseGoogle =>
      'Cet e-mail est lié à Google. Veuillez vous connecter avec Google.';

  @override
  String get emailInUsePassword =>
      'E-mail déjà enregistré. Connectez-vous ou réinitialisez votre mot de passe.';

  @override
  String get forgotPasswordBtn => 'Mot de passe oublié';

  @override
  String get fillEmailToReset =>
      'Remplissez le champ e-mail pour réinitialiser le mot de passe.';

  @override
  String get passwordResetSent =>
      'Lien de réinitialisation envoyé à votre e-mail !';

  @override
  String get myCommunity => 'Ma communauté';

  @override
  String get errorLoadingUser => 'Erreur lors du chargement de l\'utilisateur';

  @override
  String get loading => 'Chargement...';

  @override
  String get usernameInUse => 'Nom d\'utilisateur déjà utilisé.';

  @override
  String get invalidCode => 'Code invalide.';

  @override
  String get accessCodeUpdated => 'Code d\'accès mis à jour !';

  @override
  String get createCommunity => 'Créer une communauté';

  @override
  String get name => 'Nom';

  @override
  String get cancel => 'Annuler';

  @override
  String get create => 'Créer';

  @override
  String get joinCommunity => 'Rejoindre une communauté';

  @override
  String get join => 'Rejoindre';

  @override
  String get joinUsingCode => 'Rejoindre avec un code';

  @override
  String get chooseUsername => 'Choisissez votre nom d\'utilisateur';

  @override
  String get yourUsername => 'Votre nom d\'utilisateur';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get requiredField => 'Obligatoire';

  @override
  String get save => 'Enregistrer';

  @override
  String get update => 'Mettre à jour';

  @override
  String get communityNotFound => 'Communauté introuvable.';

  @override
  String get code => 'Code';

  @override
  String get weeklyRanking => 'Classement de la semaine';

  @override
  String get noMembers => 'Aucun membre.';

  @override
  String get memberRole => 'Membre';

  @override
  String get superiorAdminRole => 'Administrateur Supérieur';

  @override
  String get adminRole => 'Administrateur';

  @override
  String get you => 'Vous';

  @override
  String get kickMember => 'Expulser';

  @override
  String get makeAdmin => 'Rendre Administrateur';

  @override
  String get removeAdmin => 'Retirer Administrateur';

  @override
  String get transferSuperior => 'Transférer le rôle Supérieur';

  @override
  String timeLeft(int days, int hours) {
    return 'Il reste $days jour(s) et $hours heure(s)';
  }

  @override
  String get editCommunity => 'Modifier la communauté';

  @override
  String get newName => 'Nouveau nom';

  @override
  String get editUsername => 'Modifier le nom d\'utilisateur';

  @override
  String get newUsername => 'Nouveau nom d\'utilisateur';

  @override
  String get usernameUpdated => 'Nom d\'utilisateur mis à jour avec succès !';

  @override
  String get updateCodeTitle => 'Mettre à jour le code';

  @override
  String get updateCodeDesc =>
      'Êtes-vous sûr de vouloir générer un nouveau code d\'accès ? L\'ancien code ne fonctionnera plus pour les nouveaux membres.';

  @override
  String get attention => 'Attention';

  @override
  String get transferSuperiorBeforeLeaving =>
      'Vous devez transférer le rôle d\'Administrateur Supérieur à un autre membre avant de quitter la communauté.';

  @override
  String get ok => 'OK';

  @override
  String get leaveCommunityTitle => 'Quitter la communauté';

  @override
  String get leaveCommunityLastMember =>
      'Vous êtes le dernier membre. Si vous quittez, la communauté sera définitivement supprimée. Êtes-vous sûr ?';

  @override
  String get leaveCommunityConfirm =>
      'Êtes-vous sûr de vouloir quitter la communauté ?';

  @override
  String get leave => 'Quitter';

  @override
  String get setRewardsTitle => 'Définir la récompense';

  @override
  String get firstPlace => '1ère place';

  @override
  String get secondPlace => '2ème place';

  @override
  String get thirdPlace => '3ème place';

  @override
  String get weekDescription => 'Description de la semaine';

  @override
  String get rankingHistoryTitle => 'Historique du classement';

  @override
  String get noHistoryYet => 'Aucun historique disponible pour le moment.';

  @override
  String get unknownWeek => 'Semaine inconnue';

  @override
  String get winner => 'Gagnant';

  @override
  String get prize => 'Prix';

  @override
  String get close => 'Fermer';

  @override
  String get weeklyRewards => 'Récompenses de la semaine';

  @override
  String get noRewardsDefined => 'Aucune récompense définie.';

  @override
  String get history => 'Historique';

  @override
  String get noWinner => 'Aucun gagnant';

  @override
  String get firstPlacePrefix => '🥇 1er : ';

  @override
  String get secondPlacePrefix => '🥈 2e : ';

  @override
  String get thirdPlacePrefix => '🥉 3e : ';

  @override
  String get locationPermissionTitle => 'Autorisation de localisation';

  @override
  String get locationPermissionDesc =>
      'MovePass collecte des données de localisation pour permettre le suivi de votre itinéraire, le calcul de la vitesse et de la distance pendant les courses, même lorsque l\'application est fermée ou n\'est pas utilisée.';

  @override
  String get decline => 'Refuser';

  @override
  String get understood => 'Compris';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountTitle => 'Supprimer le compte ?';

  @override
  String get deleteAccountContent =>
      'Cela effacera toutes vos données. Êtes-vous sûr ?';

  @override
  String get continueAction => 'Continuer';

  @override
  String get finalWarningTitle => 'Avertissement final';

  @override
  String get finalWarningContent =>
      'Cette action est irréversible. Toutes vos courses, votre historique de pas et votre profil seront définitivement supprimés du serveur.';

  @override
  String get deletePermanently => 'Supprimer définitivement';

  @override
  String get deleteAccountError =>
      'Erreur lors de la suppression du compte. Veuillez vous reconnecter et réessayer.';
}
