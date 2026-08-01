from __future__ import annotations

from PySide6.QtCore import QLocale, QObject, Signal

try:
    from PySide6.QtTextToSpeech import QTextToSpeech
except ImportError:
    QTextToSpeech = None


class VoiceService(QObject):
    """
    Gère la synthèse vocale locale d'OmegaOS.

    Le service utilise le moteur vocal fourni par le système
    d'exploitation par l'intermédiaire de Qt TextToSpeech.
    """

    stateChanged = Signal()
    errorOccurred = Signal(str)

    def __init__(
        self,
        parent: QObject | None = None,
    ) -> None:
        super().__init__(parent)

        self._speech: QTextToSpeech | None = None
        self._available = False
        self._status_message = (
            "Synthèse vocale non initialisée"
        )

        self._initialize_engine()

    @property
    def available(self) -> bool:
        return self._available

    @property
    def status_message(self) -> str:
        return self._status_message

    @property
    def engine_name(self) -> str:
        if self._speech is None:
            return "Indisponible"

        engine = self._speech.engine

        if not engine:
            return "Moteur système"

        return str(engine)

    def set_volume(self, volume: float) -> None:
        """
        Définit le volume entre 0.0 et 1.0.
        """

        if self._speech is None:
            return

        normalized_volume = max(
            0.0,
            min(1.0, float(volume)),
        )

        self._speech.setVolume(normalized_volume)

    def set_rate(self, rate: float) -> None:
        """
        Définit la vitesse entre -1.0 et 1.0.
        """

        if self._speech is None:
            return

        normalized_rate = max(
            -1.0,
            min(1.0, float(rate)),
        )

        self._speech.setRate(normalized_rate)

    def speak(self, message: str) -> bool:
        """
        Prononce un texte immédiatement.

        Retourne False si aucun moteur vocal n'est disponible.
        """

        cleaned_message = message.strip()

        if not cleaned_message:
            return False

        if self._speech is None or not self._available:
            self._status_message = (
                "Aucun moteur vocal disponible"
            )
            self.errorOccurred.emit(
                self._status_message
            )
            self.stateChanged.emit()
            return False

        try:
            self._speech.stop()
            self._speech.say(cleaned_message)

            self._status_message = "Annonce en cours"
            self.stateChanged.emit()

            return True

        except Exception as error:
            self._status_message = (
                f"Erreur de synthèse vocale : {error}"
            )

            self.errorOccurred.emit(
                self._status_message
            )
            self.stateChanged.emit()

            return False

    def stop(self) -> None:
        """
        Interrompt l'annonce en cours.
        """

        if self._speech is None:
            return

        self._speech.stop()
        self._status_message = "Annonce interrompue"
        self.stateChanged.emit()

    def _initialize_engine(self) -> None:
        if QTextToSpeech is None:
            self._status_message = (
                "Le module Qt TextToSpeech est indisponible"
            )
            return

        try:
            engines = QTextToSpeech.availableEngines()

            if not engines:
                self._status_message = (
                    "Aucun moteur vocal système détecté"
                )
                return

            self._speech = QTextToSpeech(
                engines[0],
                self,
            )

            french_locale = QLocale(
                QLocale.Language.French,
                QLocale.Country.France,
            )

            available_locales = (
                self._speech.availableLocales()
            )

            if french_locale in available_locales:
                self._speech.setLocale(
                    french_locale
                )

            self._speech.stateChanged.connect(
                self._on_speech_state_changed
            )

            self._speech.errorOccurred.connect(
                self._on_speech_error
            )

            self._available = True
            self._status_message = (
                "Synthèse vocale disponible"
            )

        except Exception as error:
            self._speech = None
            self._available = False
            self._status_message = (
                f"Initialisation vocale impossible : {error}"
            )

    def _on_speech_state_changed(self, state) -> None:
        if self._speech is None:
            return

        if state == QTextToSpeech.State.Ready:
            self._status_message = "Synthèse vocale prête"

        elif state == QTextToSpeech.State.Speaking:
            self._status_message = "Annonce en cours"

        elif state == QTextToSpeech.State.Paused:
            self._status_message = "Annonce en pause"

        elif state == QTextToSpeech.State.Error:
            self._status_message = (
                self._speech.errorString()
                or "Erreur du moteur vocal"
            )

        self.stateChanged.emit()

    def _on_speech_error(
        self,
        _reason,
        error_string: str,
    ) -> None:
        self._status_message = (
            error_string
            or "Erreur du moteur vocal"
        )

        self.errorOccurred.emit(
            self._status_message
        )
        self.stateChanged.emit()