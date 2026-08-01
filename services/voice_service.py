from __future__ import annotations

from PySide6.QtCore import QLocale, QObject, Signal
from PySide6.QtTextToSpeech import QTextToSpeech


class VoiceService(QObject):
    """
    Gère la synthèse vocale locale d'OmegaOS.
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

        return self._speech.engine() or "Moteur système"

    def set_volume(self, volume: float) -> None:
        if self._speech is None:
            return

        self._speech.setVolume(
            max(0.0, min(1.0, float(volume)))
        )

    def set_rate(self, rate: float) -> None:
        if self._speech is None:
            return

        self._speech.setRate(
            max(-1.0, min(1.0, float(rate)))
        )

    def speak(self, message: str) -> bool:
        cleaned_message = message.strip()

        if not cleaned_message:
            return False

        if self._speech is None:
            self._set_error(
                "Le moteur vocal n'est pas initialisé."
            )
            return False

        if (
            self._speech.state()
            == QTextToSpeech.State.Error
        ):
            self._set_error(
                self._speech.errorString()
                or "Le moteur vocal est en erreur."
            )
            return False

        voices = self._speech.availableVoices()

        if not voices:
            self._set_error(
                "Aucune voix n'est disponible "
                "pour la langue sélectionnée."
            )
            return False

        try:
            self._speech.stop()
            self._speech.say(cleaned_message)

            self._status_message = (
                "Annonce demandée au moteur vocal"
            )
            self.stateChanged.emit()

            return True

        except Exception as error:
            self._set_error(
                f"Erreur de synthèse vocale : {error}"
            )
            return False

    def stop(self) -> None:
        if self._speech is None:
            return

        self._speech.stop()
        self._status_message = "Annonce interrompue"
        self.stateChanged.emit()

    def _initialize_engine(self) -> None:
        try:
            engines = QTextToSpeech.availableEngines()

            if not engines:
                self._status_message = (
                    "Aucun moteur vocal Qt détecté"
                )
                return

            # Utilise d'abord le moteur par défaut du système.
            self._speech = QTextToSpeech(self)

            self._speech.stateChanged.connect(
                self._on_speech_state_changed
            )

            self._speech.errorOccurred.connect(
                self._on_speech_error
            )

            french_locale = self._find_french_locale()

            if french_locale is not None:
                self._speech.setLocale(french_locale)

            voices = self._speech.availableVoices()

            if voices:
                # Sélection explicite de la première voix compatible.
                self._speech.setVoice(voices[0])

                voice_name = voices[0].name()
                locale_name = (
                    self._speech.locale().name()
                )

                self._status_message = (
                    f"Voix prête : {voice_name} "
                    f"({locale_name})"
                )

                self._available = True
            else:
                self._status_message = (
                    "Moteur détecté, mais aucune voix "
                    "compatible n'est installée"
                )

        except Exception as error:
            self._speech = None
            self._available = False

            self._status_message = (
                f"Initialisation vocale impossible : "
                f"{error}"
            )

    def _find_french_locale(
        self,
    ) -> QLocale | None:
        if self._speech is None:
            return None

        available_locales = (
            self._speech.availableLocales()
        )

        preferred_locale = QLocale(
            QLocale.Language.French,
            QLocale.Country.France,
        )

        for locale in available_locales:
            if locale == preferred_locale:
                return locale

        for locale in available_locales:
            if (
                locale.language()
                == QLocale.Language.French
            ):
                return locale

        # En dernier recours, conserve la langue système.
        if available_locales:
            return available_locales[0]

        return None

    def _on_speech_state_changed(
        self,
        state: QTextToSpeech.State,
    ) -> None:
        if self._speech is None:
            return

        if state == QTextToSpeech.State.Ready:
            self._status_message = (
                "Synthèse vocale prête"
            )

        elif state == QTextToSpeech.State.Speaking:
            self._status_message = (
                "Annonce en cours"
            )

        elif state == QTextToSpeech.State.Paused:
            self._status_message = (
                "Annonce en pause"
            )

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
        self._set_error(
            error_string
            or "Erreur du moteur vocal"
        )

    def _set_error(self, message: str) -> None:
        self._status_message = message
        self.errorOccurred.emit(message)
        self.stateChanged.emit()