// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get todayTitle => 'Hoy';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get reportsTitle => 'Informes';

  @override
  String get backupTitle => 'Copia y restauración';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navReports => 'Informes';

  @override
  String get navBackup => 'Copia y restauración';

  @override
  String get startWork => 'Iniciar';

  @override
  String get stopWork => 'Detener';

  @override
  String get running => 'En curso';

  @override
  String get inProgress => 'En progreso';

  @override
  String get idle => 'Inactivo';

  @override
  String totalToday(String duration) {
    return 'Total de hoy: $duration';
  }

  @override
  String get noSessionsYet => 'Todavía no hay sesiones';

  @override
  String get noPlannedBlocks => 'No hay bloques planificados';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get weeklyTemplates => 'Plantillas semanales';

  @override
  String get addPlannedBlock => 'Añadir bloque planificado';

  @override
  String get editPlannedBlock => 'Editar bloque planificado';

  @override
  String get planned => 'Planificado';

  @override
  String get actual => 'Real';

  @override
  String get variance => 'Diferencia';

  @override
  String get deletePlannedBlock => 'Eliminar bloque planificado';

  @override
  String get startTime => 'Inicio (HH:MM)';

  @override
  String get endTime => 'Fin (HH:MM)';

  @override
  String get noteOptional => 'Nota (opcional)';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get createWeeklyTemplate => 'Crear plantilla semanal';

  @override
  String get name => 'Nombre';

  @override
  String get weekday => 'Día de la semana';

  @override
  String get saveAndApply => 'Guardar y aplicar';

  @override
  String get validTimeRangeError =>
      'Introduce un intervalo válido que no cruce la medianoche';

  @override
  String get nameAndTimeRangeError =>
      'Introduce un nombre y un intervalo válido';

  @override
  String get weekdayMonday => 'Lunes';

  @override
  String get weekdayTuesday => 'Martes';

  @override
  String get weekdayWednesday => 'Miércoles';

  @override
  String get weekdayThursday => 'Jueves';

  @override
  String get weekdayFriday => 'Viernes';

  @override
  String get weekdaySaturday => 'Sábado';

  @override
  String get weekdaySunday => 'Domingo';

  @override
  String get exportCsv => 'Exportar CSV';

  @override
  String get reportPeriod => 'Período del informe';

  @override
  String get periodDay => 'Día';

  @override
  String get periodWeek => 'Semana';

  @override
  String get periodMonth => 'Mes';

  @override
  String get dailySummary => 'Resumen diario';

  @override
  String get weeklySummary => 'Resumen semanal';

  @override
  String get monthlySummary => 'Resumen mensual';

  @override
  String get couldNotLoadReport => 'No se pudo cargar el informe';

  @override
  String get csvReadyToShare => 'CSV listo para compartir';

  @override
  String get couldNotExportReport => 'No se pudo exportar el informe';

  @override
  String get sessions => 'Sesiones';

  @override
  String get noSessionsForDay => 'No hay sesiones para este día';

  @override
  String get couldNotLoadSessions => 'No se pudieron cargar las sesiones';

  @override
  String get deleteSessionQuestion => '¿Eliminar sesión?';

  @override
  String get deleteSessionBody =>
      'Se eliminará este registro de tiempo trabajado.';

  @override
  String get delete => 'Eliminar';

  @override
  String get sessionActions => 'Acciones de sesión';

  @override
  String get editSession => 'Editar sesión';

  @override
  String get deleteSession => 'Eliminar sesión';

  @override
  String get startLabel => 'Inicio';

  @override
  String get endLabel => 'Fin';

  @override
  String get endMustFollowStart =>
      'La hora de fin debe ser posterior al inicio';

  @override
  String get couldNotUpdateSession => 'No se pudo actualizar la sesión';

  @override
  String get couldNotDeleteSession => 'No se pudo eliminar la sesión';

  @override
  String get backupIntro =>
      'TimeFlow guarda tus datos de trabajo en este dispositivo. Crea una copia JSON y guárdala en un lugar seguro. Restaurar reemplaza todos los datos actuales de TimeFlow en este dispositivo.';

  @override
  String get createBackup => 'Crear copia de seguridad';

  @override
  String get restoreFromFile => 'Restaurar desde archivo';

  @override
  String get backupContents =>
      'Las copias incluyen sesiones, bloques planificados, plantillas semanales y preferencias de recordatorios. TimeFlow no carga estos datos salvo que elijas un destino para compartir.';

  @override
  String get privacyControls => 'Controles de privacidad';

  @override
  String get deleteAllLocalDataDescription =>
      'Elimina sesiones, planes, plantillas y preferencias guardadas en este dispositivo. No elimina copias compartidas o guardadas fuera de TimeFlow.';

  @override
  String get deleteAllLocalData => 'Eliminar todos los datos locales';

  @override
  String get replaceLocalDataQuestion => '¿Reemplazar los datos locales?';

  @override
  String get replaceLocalDataBody =>
      'La copia seleccionada reemplazará todas las sesiones, planes, plantillas y preferencias de recordatorios de este dispositivo. No se puede deshacer.';

  @override
  String get replaceData => 'Reemplazar datos';

  @override
  String get deleteAllDataQuestion => '¿Eliminar todos los datos locales?';

  @override
  String get deleteAllDataBody =>
      'Se eliminarán permanentemente todas las sesiones, planes, plantillas y preferencias de recordatorios de este dispositivo. No se puede deshacer.';

  @override
  String get deletePermanently => 'Eliminar permanentemente';

  @override
  String get backupReadyToSave => 'Copia lista para guardar';

  @override
  String get backupRestored => 'Copia restaurada';

  @override
  String get allLocalDataDeleted =>
      'Se eliminaron todos los datos locales de TimeFlow';

  @override
  String get couldNotCreateBackup => 'No se pudo crear la copia';

  @override
  String get couldNotRestoreBackup => 'No se pudo restaurar la copia';

  @override
  String get couldNotDeleteLocalData =>
      'No se pudieron eliminar los datos locales';
}
