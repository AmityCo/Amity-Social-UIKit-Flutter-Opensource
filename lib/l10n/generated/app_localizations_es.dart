// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get community_title => 'Comunidad';

  @override
  String get tab_newsfeed => 'Noticias';

  @override
  String get tab_explore => 'Explorar';

  @override
  String get tab_my_communities => 'Mis Comunidades';

  @override
  String get global_search_hint => 'Buscar comunidad y usuario';

  @override
  String get search_my_community_hint => 'Buscar mi comunidad';

  @override
  String get search_no_results => 'No se encontraron resultados';

  @override
  String get title_communities => 'Comunidades';

  @override
  String get title_users => 'Usuarios';

  @override
  String get general_cancel => 'Cancelar';

  @override
  String get general_ok => 'OK';

  @override
  String get general_confirm => 'Confirmar';

  @override
  String get general_featured => 'Destacado';

  @override
  String get profile_followers => 'Seguidores';

  @override
  String get profile_following => 'Siguiendo';

  @override
  String get profile_posts => 'Publicaciones';

  @override
  String get post_create => 'Crear publicación';

  @override
  String get post_edit => 'Editar publicación';

  @override
  String get post_create_hint => '¿Qué está pasando...?';

  @override
  String get post_delete => 'Eliminar publicación';

  @override
  String get post_delete_description => 'Esta publicación se eliminará permanentemente.';

  @override
  String get post_delete_confirmation => '¿Eliminar publicación?';

  @override
  String get post_delete_confirmation_description => '¿Quieres eliminar tu publicación?';

  @override
  String get post_report => 'Reportar publicación';

  @override
  String get post_unreport => 'Desreportar publicación';

  @override
  String get post_like => 'Me gusta';

  @override
  String get post_comment => 'Comentar';

  @override
  String get post_share => 'Compartir';

  @override
  String get post_discard => '¿Descartar esta publicación?';

  @override
  String get post_discard_description => 'La publicación se eliminará permanentemente. No se puede deshacer.';

  @override
  String get post_write_comment => 'Escribe un comentario...';

  @override
  String get poll_duration => 'Duración de la encuesta';

  @override
  String get poll_duration_hint => 'Siempre puedes cerrar la encuesta antes de la duración establecida.';

  @override
  String get poll_custom_edn_date => 'Fecha de finalización personalizada';

  @override
  String get poll_close => 'Cerrar encuesta';

  @override
  String get poll_close_description => 'Esta encuesta está cerrada. Ya no puedes votar.';

  @override
  String get poll_vote => 'Votar';

  @override
  String get poll_results => 'Ver resultados';

  @override
  String get poll_back_to_vote => 'Volver a votar';

  @override
  String poll_vote_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String poll_total_votes(int count, String plusSign) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Votado por $count$plusSign participantes',
      one: 'Votado por 1 participante',
      zero: 'Sin votos',
    );
    return '$_temp0';
  }

  @override
  String poll_see_more_options(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count opciones más',
      one: 'Ver 1 opción más',
    );
    return '$_temp0';
  }

  @override
  String get poll_see_full_results => 'Ver resultados completos';

  @override
  String get poll_voted => 'Votado por ti';

  @override
  String get poll_and_you => ' y tú';

  @override
  String get poll_remaining_time => 'restante';

  @override
  String get poll_vote_error => 'Error al votar en la encuesta. Por favor, inténtalo de nuevo.';

  @override
  String get poll_ended => 'Finalizado';

  @override
  String get poll_single_choice => 'Selecciona una opción';

  @override
  String get poll_multiple_choice => 'Selecciona una o más opciones';

  @override
  String poll_options_description(int minOptions) {
    return 'La encuesta debe contener al menos $minOptions opciones.';
  }

  @override
  String get poll_question => 'Pregunta de la encuesta';

  @override
  String get poll_question_hint => '¿Cuál es tu pregunta de la encuesta?';

  @override
  String get comment_create_hint => 'Di algo bonito...';

  @override
  String get comment_reply => 'Responder';

  @override
  String get comment_reply_to => 'Respondiendo a ';

  @override
  String comment_view_reply_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count respuestas',
      one: 'Ver 1 respuesta',
    );
    return '$_temp0';
  }

  @override
  String get comment_report => 'Reportar comentario';

  @override
  String get comment_unreport => 'Quitar reporte';

  @override
  String get comment_reply_report => 'Reportar respuesta';

  @override
  String get comment_reply_unreport => 'Quitar reporte';

  @override
  String get comment_edit => 'Editar comentario';

  @override
  String get comment_reply_edit => 'Editar respuesta';

  @override
  String get comment_delete => 'Eliminar comentario';

  @override
  String get comment_reply_delete => 'Eliminar respuesta';

  @override
  String comment_delete_description(String content) {
    return 'Este $content será eliminado permanentemente.';
  }

  @override
  String get comment_create_error_ban_word => 'Tu comentario contiene una palabra inapropiada. Por favor, revísalo y elimínalo.';

  @override
  String get comment_create_error_story_deleted => 'Esta historia ya no está disponible';

  @override
  String get community_create_success_message => 'Comunidad creada exitosamente.';

  @override
  String get community_create_error_message => 'No se pudo crear la comunidad. Por favor, inténtalo de nuevo.';

  @override
  String get community_update_success_message => 'Comunidad actualizada exitosamente.';

  @override
  String get community_update_error_message => 'No se pudo guardar el perfil de la comunidad. Por favor, inténtalo de nuevo.';

  @override
  String get community_leave_success_message => 'Has salido de la comunidad exitosamente.';

  @override
  String get community_leave_error_message => 'No se pudo salir de la comunidad.';

  @override
  String get community_close_success_message => 'Comunidad cerrada exitosamente.';

  @override
  String get community_close_error_message => 'No se pudo cerrar la comunidad.';

  @override
  String get community_close => '¿Cerrar comunidad?';

  @override
  String get community_close_description => 'Todos los miembros serán removidos de la comunidad. Todas las publicaciones, mensajes, reacciones y medios compartidos en la comunidad serán eliminados. Esto no se puede deshacer.';

  @override
  String get community_join => 'Unirse';

  @override
  String get community_joined => 'Unido';

  @override
  String get community_recommended_for_you => 'Recomendado para ti';

  @override
  String get community_trending_now => 'Tendencia ahora';

  @override
  String get community_placeholder_members => '1.2K miembros';

  @override
  String get community_leave => 'Salir de la comunidad';

  @override
  String get community_leave_description => 'Salir de la comunidad. Ya no podrás publicar e interactuar en esta comunidad.';

  @override
  String get community_create => 'Crear Comunidad';

  @override
  String get community_name => 'Nombre de la comunidad';

  @override
  String get community_name_hint => 'Nombra tu comunidad';

  @override
  String get community_description_hint => 'Ingresa la descripción';

  @override
  String get community_edit => 'Editar Comunidad';

  @override
  String get community_members => 'Miembros';

  @override
  String get community_private => 'Privada';

  @override
  String get community_public => 'Pública';

  @override
  String get community_public_description => 'Cualquiera puede unirse, ver y buscar las publicaciones en esta comunidad.';

  @override
  String get community_private_description => 'Solo los miembros invitados por los moderadores pueden unirse, ver y buscar las publicaciones en esta comunidad.';

  @override
  String get community_about => 'Acerca de';

  @override
  String get categories_title => 'Categorías';

  @override
  String get category_hint => 'Seleccionar categoría';

  @override
  String get category_select_title => 'Seleccionar Categoría';

  @override
  String get category_add => 'Agregar Categoría';

  @override
  String get community_pending_posts => 'Publicaciones Pendientes';

  @override
  String get commnuity_pending_post_reviewing => 'Tus publicaciones están pendientes de revisión';

  @override
  String commnuity_pending_post_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones necesitan aprobación',
      one: '$count publicación necesita aprobación',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Solicitudes pendientes',
      one: 'Solicitud pendiente',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_message(String displayCount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicaciones requieren',
      one: 'publicación requiere',
    );
    return '$displayCount $_temp0 aprobación';
  }

  @override
  String get community_basic_info => 'Información Básica';

  @override
  String get community_discard_confirmation => '¿Salir sin terminar?';

  @override
  String get community_discard_description => 'Tu progreso no será guardado y tu comunidad no será creada.';

  @override
  String get message_send => 'Enviar';

  @override
  String get message_typing => 'está escribiendo...';

  @override
  String get message_placeholder => 'Escribe un mensaje...';

  @override
  String get settings_title => 'Configuración';

  @override
  String get settings_notifications => 'Notificaciones';

  @override
  String get settings_new_posts => 'Nuevas publicaciones';

  @override
  String get settings_new_posts_description => 'Recibe notificaciones cuando alguien cree nuevas publicaciones en esta comunidad.';

  @override
  String get settings_react_posts => 'Reacciones a publicaciones';

  @override
  String get settings_react_posts_description => 'Recibe notificaciones cuando alguien reaccione a tus publicaciones en esta comunidad.';

  @override
  String get settings_react_comments => 'Reacciones a comentarios';

  @override
  String get settings_react_comments_description => 'Recibe notificaciones cuando alguien le dé me gusta a tu comentario en esta comunidad.';

  @override
  String get settings_new_comments => 'Nuevos comentarios';

  @override
  String get settings_new_comments_description => 'Recibe notificaciones cuando alguien comente en tu publicación en esta comunidad.';

  @override
  String get settings_new_replies => 'Respuestas';

  @override
  String get settings_new_replies_description => 'Recibe notificaciones cuando alguien comente en tus comentarios en esta comunidad.';

  @override
  String get settings_allow_stories_comments => 'Permitir comentarios en historias de la comunidad';

  @override
  String get settings_allow_stories_comments_description => 'Activa para recibir comentarios en las historias de esta comunidad.';

  @override
  String get settings_new_stories => 'Nuevas historias';

  @override
  String get settings_new_stories_description => 'Recibe notificaciones cuando alguien cree una nueva historia en esta comunidad.';

  @override
  String get settings_story_reactions => 'Reacciones a historias';

  @override
  String get settings_story_reactions_description => 'Recibe notificaciones cuando alguien reaccione a tu historia en esta comunidad.';

  @override
  String get settings_story_comments => 'Comentarios de historias';

  @override
  String get settings_story_comments_description => 'Recibe notificaciones cuando alguien comente en tu historia en esta comunidad.';

  @override
  String get settings_everyone => 'Todos';

  @override
  String get settings_only_moderators => 'Solo moderadores';

  @override
  String get settings_only_admins => 'Solo los administradores pueden publicar';

  @override
  String get settings_privacy => 'Privacidad';

  @override
  String get settings_permissions => 'Permisos de la comunidad';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_leave_confirmation => '¿Salir sin terminar?';

  @override
  String get settings_leave_description => 'Los cambios que hiciste pueden no ser guardados.';

  @override
  String get settings_privacy_confirmation => '¿Cambiar configuración de privacidad de la comunidad?';

  @override
  String get settings_privacy_description => 'Esta comunidad tiene publicaciones destacadas globalmente. Cambiar la comunidad de pública a privada eliminará estas publicaciones de ser destacadas globalmente.';

  @override
  String get general_add => 'Agregar';

  @override
  String get general_loading => 'Cargando...';

  @override
  String get general_leave => 'Salir';

  @override
  String get general_error => 'Ups, algo salió mal';

  @override
  String get general_edited => 'Editado';

  @override
  String get general_edited_suffix => ' (editado)';

  @override
  String get general_keep_editing => 'Seguir editando';

  @override
  String get general_discard => 'Descartar';

  @override
  String get general_moderator => 'Moderador';

  @override
  String get general_save => 'Guardar';

  @override
  String get general_delete => 'Eliminar';

  @override
  String get general_edit => 'Editar';

  @override
  String get general_close => 'Cerrar';

  @override
  String get general_done => 'Listo';

  @override
  String get general_post => 'Publicar';

  @override
  String get general_comments => 'Comentarios';

  @override
  String get general_story => 'Historia';

  @override
  String get general_stories => 'Historias';

  @override
  String get general_poll => 'Encuesta';

  @override
  String get general_optional => 'Opcional';

  @override
  String get general_on => 'Activado';

  @override
  String get general_off => 'Desactivado';

  @override
  String get settings_allow_notification => 'Permitir Notificaciones';

  @override
  String get settings_allow_notification_description => 'Activa para recibir notificaciones push de esta comunidad.';

  @override
  String get general_reported => 'reportado';

  @override
  String get general_unreported => 'no reportado';

  @override
  String get general_see_more => '...Ver más';

  @override
  String get general_camera => 'Cámara';

  @override
  String get general_photo => 'Foto';

  @override
  String get general_video => 'Video';

  @override
  String get general_posting => 'Publicando';

  @override
  String get general_my_timeline => 'Mi Cronología';

  @override
  String get general_options => 'Opciones';

  @override
  String get post_edit_globally_featured => '¿Editar publicación destacada globalmente?';

  @override
  String get post_edit_globally_featured_description => 'La publicación que estás editando ha sido destacada globalmente. Si editas tu publicación, necesitará ser re-aprobada y ya no será destacada globalmente.';

  @override
  String post_like_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '1 me gusta',
    );
    return '$_temp0';
  }

  @override
  String post_comment_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentarios',
      one: '1 comentario',
    );
    return '$_temp0';
  }

  @override
  String get post_reported => 'Publicación reportada.';

  @override
  String get post_unreported => 'Reporte de publicación removido.';

  @override
  String profile_followers_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seguidores',
      one: '1 seguidor',
      zero: 'Sin seguidores',
    );
    return '$_temp0';
  }

  @override
  String community_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
      zero: 'Sin miembros',
    );
    return '$_temp0';
  }

  @override
  String profile_posts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicaciones',
      one: 'publicación',
    );
    return '$_temp0';
  }

  @override
  String profile_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'miembros',
      one: 'miembro',
    );
    return '$_temp0';
  }

  @override
  String get user_block => 'Bloquear Usuario';

  @override
  String get user_unblock => 'Desbloquear usuario';

  @override
  String get error_delete_post => 'Error al eliminar la publicación. Por favor, inténtalo de nuevo.';

  @override
  String get error_leave_community => 'No se puede salir de la comunidad';

  @override
  String get error_leave_community_description => 'Eres el único moderador de este grupo. Para salir de la comunidad, nombra a otros miembros al rol de moderador';

  @override
  String get error_close_community => 'No se pudo cerrar la comunidad';

  @override
  String get error_close_community_description => 'Algo salió mal. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get error_max_upload_reached => 'Límite máximo de carga alcanzado';

  @override
  String error_max_upload_image_reached_description(int maxUploads) {
    return 'Has alcanzado el límite de carga de $maxUploads imágenes. Cualquier imagen adicional no será guardada.';
  }

  @override
  String error_max_upload_videos_reached_description(int maxUploads) {
    return 'Has alcanzado el límite de carga de $maxUploads videos. Cualquier video adicional no será guardado.';
  }

  @override
  String get error_edit_post => 'Error al editar la publicación. Por favor, inténtalo de nuevo.';

  @override
  String get error_create_post => 'Error al crear la publicación. Por favor, inténtalo de nuevo.';

  @override
  String error_max_poll_characters(int maxQuestionLength) {
    return 'La pregunta de la encuesta no puede exceder $maxQuestionLength caracteres.';
  }

  @override
  String error_max_poll_option_characters(int maxQuestionLength) {
    return 'La opción de la encuesta no puede exceder $maxQuestionLength caracteres.';
  }

  @override
  String get error_create_poll => 'Error al crear la encuesta. Por favor, inténtalo de nuevo.';

  @override
  String get error_message_too_long_title => 'No se puede enviar el mensaje';

  @override
  String get error_message_too_long_description => 'Tu mensaje es demasiado largo. Por favor, acorta tu mensaje e inténtalo de nuevo.';

  @override
  String get user_profile_unknown_name => 'Desconocido';

  @override
  String get user_profile_deleted_name => 'Usuario eliminado';

  @override
  String get community_all_members => 'Todos los miembros';

  @override
  String get community_moderators => 'Moderadores';

  @override
  String get community_search_member_hint => 'Buscar miembro';

  @override
  String get community_promote_moderator => 'Promover a moderador';

  @override
  String get community_demote_member => 'Degradar a miembro';

  @override
  String get community_remove_member => 'Eliminar de la comunidad';

  @override
  String get user_report => 'Reportar usuario';

  @override
  String get user_unreport => 'Desreportar usuario';

  @override
  String get feed_no_videos => 'Aún no hay videos';

  @override
  String get feed_no_photos => 'Aún no hay fotos';

  @override
  String get feed_no_pinned_posts => 'Aún no hay publicaciones fijadas';

  @override
  String get feed_no_posts => 'Aún no hay publicaciones';

  @override
  String get member_add => 'Agregar miembro';

  @override
  String get search_user_hint => 'Buscar usuario';

  @override
  String get profile_edit => 'Editar perfil';

  @override
  String get profile_update_success => '¡Perfil actualizado exitosamente!';

  @override
  String get profile_update_failed => 'Error al guardar tu perfil. Por favor, inténtalo de nuevo.';

  @override
  String get community_post_permission => 'Permiso de publicación';

  @override
  String get community_story_comments => 'Comentarios de historias';

  @override
  String get community_setting_close_label => 'Cerrar comunidad';

  @override
  String get community_setting_close_description => 'Cerrar esta comunidad eliminará la página de la comunidad y todo su contenido y comentarios.';

  @override
  String get community_post_permission_title_label => 'Quién puede publicar en esta comunidad';

  @override
  String get community_post_permission_description_label => 'Puedes controlar quién puede crear publicaciones en tu comunidad.';

  @override
  String get post_item_bottom_nonmember_label => 'Súmate a la comunidad para interactuar con todos los posts';

  @override
  String get notification_turn_on_success => 'Notificación activada';

  @override
  String get notification_turn_on_error => 'Error al activar la notificación. Por favor, inténtalo de nuevo.';

  @override
  String get notification_turn_off_success => 'Notificación desactivada';

  @override
  String get notification_turn_off_error => 'Error al desactivar la notificación. Por favor, inténtalo de nuevo.';

  @override
  String get user_report_success => 'Usuario reportado.';

  @override
  String get user_report_error => 'Error al reportar usuario. Por favor, inténtalo de nuevo.';

  @override
  String get user_unreport_success => 'Usuario no reportado.';

  @override
  String get user_unreport_error => 'Error al cancelar el reporte del usuario. Por favor, inténtalo de nuevo.';

  @override
  String get user_block_success => 'Usuario bloqueado.';

  @override
  String get user_block_error => 'Error al bloquear usuario. Por favor, inténtalo de nuevo.';

  @override
  String get user_unblock_success => 'Usuario desbloqueado.';

  @override
  String get user_unblock_error => 'Error al desbloquear usuario. Por favor, inténtalo de nuevo.';

  @override
  String get search_no_members_found => 'No se encontraron miembros';

  @override
  String get moderator_promotion_title => 'Promoción a moderador';

  @override
  String get moderator_promotion_description => '¿Estás seguro de que quieres promover a este miembro a Moderador? Tendrá acceso a todas las funciones de moderador.';

  @override
  String get moderator_promote_button => 'Promover';

  @override
  String get moderator_demotion_title => 'Degradación de moderador';

  @override
  String get moderator_demotion_description => '¿Estás seguro de que quieres degradar a este Moderador? Perderá el acceso a todas las funciones de moderador.';

  @override
  String get moderator_demote_button => 'Degradar';

  @override
  String get member_removal_confirm_title => 'Confirmar eliminación';

  @override
  String get member_removal_confirm_description => '¿Estás seguro de que quieres eliminar a este miembro del grupo? Se dará cuenta de su eliminación.';

  @override
  String get member_remove_button => 'Eliminar';

  @override
  String get user_ban_confirm_title => 'Confirmar prohibición';

  @override
  String get user_ban_confirm_description => '¿Estás seguro de que quieres prohibir a este usuario? Será eliminado del grupo y no podrá encontrarlo ni volver a unirse a menos que sea desbloqueado.';

  @override
  String get user_ban_button => 'Prohibir';

  @override
  String get member_add_success => 'Miembro agregado exitosamente a esta comunidad.';

  @override
  String get member_add_error => 'Error al agregar miembro. Por favor, inténtalo de nuevo.';

  @override
  String get moderator_promote_success => 'Promovido exitosamente a moderador.';

  @override
  String get moderator_promote_error => 'Error al promover miembro. Por favor, inténtalo de nuevo.';

  @override
  String get moderator_demote_success => 'Degradado exitosamente a miembro.';

  @override
  String get moderator_demote_error => 'Error al degradar miembro. Por favor, inténtalo de nuevo.';

  @override
  String get member_remove_success => 'Miembro eliminado de esta comunidad.';

  @override
  String get member_remove_error => 'Error al eliminar miembro. Por favor, inténtalo de nuevo.';

  @override
  String get user_follow_success => 'Usuario seguido.';

  @override
  String get user_follow_error => 'Ups, algo salió mal.';

  @override
  String get user_unfollow_success => 'Usuario no seguido.';

  @override
  String get user_unfollow_error => 'Ups, algo salió mal.';

  @override
  String get post_target_selection_title => 'Publicar en';

  @override
  String get user_feed_blocked_title => 'Has bloqueado a este usuario';

  @override
  String get user_feed_blocked_description => 'Desbloquea para ver sus publicaciones.';

  @override
  String get user_feed_private_title => 'Esta cuenta es privada';

  @override
  String get user_feed_private_description => 'Sigue a este usuario para ver sus publicaciones.';

  @override
  String get timestamp_just_now => 'Ahora mismo';

  @override
  String get timestamp_now => 'ahora';

  @override
  String get chat_notification_turn_on => 'Activar notificaciones';

  @override
  String get chat_notification_turn_off => 'Desactivar notificaciones';

  @override
  String get chat_block_user_title => '¿Bloquear usuario?';

  @override
  String chat_block_user_description(String displayName) {
    return '$displayName no podrá enviarte mensajes. No se le notificará que lo has bloqueado.';
  }

  @override
  String get chat_unblock_user_title => '¿Desbloquear usuario?';

  @override
  String chat_unblock_user_description(String displayName) {
    return '$displayName ahora podrá enviarte mensajes. No se le notificará que lo has desbloqueado.';
  }

  @override
  String get chat_message_photo => 'Enviar una foto';

  @override
  String get chat_message_video => 'Enviar un video';

  @override
  String get user_follow_request_new => 'Nuevas solicitudes de seguimiento';

  @override
  String user_follow_request_approval(String count) {
    return '$count solicitudes necesitan tu aprobación';
  }

  @override
  String get user_unfollow => 'Dejar de seguir';

  @override
  String get user_follow_unable_title => 'No se puede seguir a este usuario';

  @override
  String get user_follow_unable_description => '¡Ups! Algo salió mal. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get user_follow => 'Seguir';

  @override
  String get user_follow_cancel => 'Cancelar solicitud';

  @override
  String get user_following => 'Siguiendo';

  @override
  String get user_block_confirm_title => '¿Bloquear usuario?';

  @override
  String user_block_confirm_description(String displayName) {
    return '$displayName no podrá ver las publicaciones ni los comentarios que hayas creado. No se le notificará que lo has bloqueado.';
  }

  @override
  String get user_block_confirm_button => 'Bloquear';

  @override
  String get user_unblock_confirm_title => '¿Desbloquear usuario?';

  @override
  String user_unblock_confirm_description(String displayName) {
    return '$displayName ahora podrá ver las publicaciones y los comentarios que hayas creado. No se le notificará que lo has desbloqueado.';
  }

  @override
  String get user_unblock_confirm_button => 'Desbloquear';

  @override
  String get user_unfollow_confirm_title => '¿Dejar de seguir a este usuario?';

  @override
  String get user_unfollow_confirm_description => 'Si cambias de opinión, tendrás que enviar una solicitud para seguirlo nuevamente.';

  @override
  String get user_unfollow_confirm_button => 'Dejar de seguir';

  @override
  String get category_default_title => 'Categoría';

  @override
  String get community_empty_state => 'Aún no hay comunidad';

  @override
  String get community_pending_requests_title => 'Solicitudes pendientes';

  @override
  String get community_pending_requests_empty_title => 'No hay solicitudes pendientes';

  @override
  String get community_pending_requests_empty_description => 'Habilita la revisión de publicaciones o la aprobación de unirse en la configuración de la comunidad para gestionar solicitudes.';

  @override
  String get community_join_requests_coming_soon => 'La función de solicitudes para unirse estará disponible pronto';

  @override
  String get community_pending_posts_warning => 'Rechazar una publicación pendiente eliminará permanentemente la publicación seleccionada de la comunidad.';

  @override
  String get community_pending_posts_empty => 'No hay publicaciones pendientes';

  @override
  String get community_pending_post_accept => 'Aceptar';

  @override
  String get community_pending_post_decline => 'Rechazar';

  @override
  String get community_pending_post_delete_success => 'Publicación eliminada.';

  @override
  String get community_pending_post_delete_error => 'No se pudo eliminar la publicación. Por favor, inténtalo de nuevo.';

  @override
  String get community_pending_post_approve_success => 'Publicación aceptada.';

  @override
  String get community_pending_post_approve_error => 'No se pudo aceptar la publicación. Esta publicación ya ha sido revisada por otro moderador.';

  @override
  String get community_pending_post_decline_success => 'Publicación rechazada.';

  @override
  String get community_pending_post_decline_error => 'No se pudo rechazar la publicación. Esta publicación ya ha sido revisada por otro moderador.';

  @override
  String poll_option_hint(int optionNumber) {
    return 'Opción $optionNumber';
  }

  @override
  String get poll_add_option => 'Agregar opción';

  @override
  String get poll_multiple_selection_title => 'Selección múltiple';

  @override
  String get poll_multiple_selection_description => 'Permitir que los participantes voten más de una opción.';

  @override
  String poll_ends_on(String endDate) {
    return 'Termina el $endDate';
  }

  @override
  String get poll_ends_on_label => 'Termina el';

  @override
  String get poll_select_date => 'Seleccionar fecha';

  @override
  String get poll_select_time => 'Seleccionar hora';

  @override
  String poll_duration_days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get poll_time_hour => 'Hora';

  @override
  String get poll_time_minute => 'Minuto';

  @override
  String get profile_edit_display_name => 'Nombre para mostrar';

  @override
  String get profile_edit_about => 'Acerca de';

  @override
  String get profile_edit_unsupported_image_title => 'Tipo de imagen no compatible';

  @override
  String get profile_edit_unsupported_image_description => 'Por favor, sube una imagen en formato PNG o JPG.';

  @override
  String get profile_edit_inappropriate_image_title => 'Imagen inapropiada';

  @override
  String get profile_edit_inappropriate_image_description => 'Por favor, elige una imagen diferente para subir.';

  @override
  String get profile_edit_unsaved_changes_title => 'Cambios no guardados';

  @override
  String get profile_edit_unsaved_changes_description => '¿Estás seguro de que quieres descartar los cambios? Se perderán al salir de esta página.';

  @override
  String get chat_title => 'Chat';

  @override
  String get chat_tab_all => 'Todos';

  @override
  String get chat_tab_direct => 'Directos';

  @override
  String get chat_tab_groups => 'Grupos';

  @override
  String get chat_waiting_for_network => 'Esperando conexión de red...';

  @override
  String get chat_direct_chat => 'Chat directo';

  @override
  String get chat_group_chat => 'Chat grupal';

  @override
  String get chat_archived => 'Archivados';

  @override
  String get message_editing_message => 'Editando mensaje';

  @override
  String get message_replying_yourself => 'tú mismo';

  @override
  String get message_replied_message => 'Mensaje respondido';

  @override
  String message_replying_to(String displayName) {
    return 'Respondiendo a $displayName';
  }

  @override
  String get message_media => 'Multimedia';

  @override
  String get chat_loading => 'Cargando chat...';

  @override
  String get chat_blocked_message => 'No puedes enviar mensajes a esta persona.';

  @override
  String get chat_notifications_disabled => 'Has desactivado las notificaciones del chat';

  @override
  String get chat_archive => 'Archivar';

  @override
  String get chat_unarchive => 'Desarchivar';

  @override
  String get chat_message_deleted => 'Este mensaje fue eliminado';

  @override
  String get chat_message_no_preview => 'No se admite vista previa para este tipo de mensaje';

  @override
  String get chat_no_message_yet => 'Aún no hay mensajes';
}

/// The translations for Spanish Castilian, as used in Chile (`es_CL`).
class AppLocalizationsEsCl extends AppLocalizationsEs {
  AppLocalizationsEsCl(): super('es_CL');

  @override
  String get community_title => 'Comunidad';

  @override
  String get tab_newsfeed => 'Noticias';

  @override
  String get tab_explore => 'Explorar';

  @override
  String get tab_my_communities => 'Mis Comunidades';

  @override
  String get global_search_hint => 'Buscar comunidad y usuario';

  @override
  String get search_my_community_hint => 'Buscar mi comunidad';

  @override
  String get search_no_results => 'No se encontraron resultados';

  @override
  String get title_communities => 'Comunidades';

  @override
  String get title_users => 'Usuarios';

  @override
  String get general_cancel => 'Cancelar';

  @override
  String get general_ok => 'OK';

  @override
  String get general_confirm => 'Confirmar';

  @override
  String get general_featured => 'Destacado';

  @override
  String get profile_followers => 'Seguidores';

  @override
  String get profile_following => 'Siguiendo';

  @override
  String get profile_posts => 'Publicaciones';

  @override
  String get post_create => 'Crear publicación';

  @override
  String get post_edit => 'Editar publicación';

  @override
  String get post_create_hint => '¿Qué está pasando...?';

  @override
  String get post_delete => 'Eliminar publicación';

  @override
  String get post_delete_description => 'Esta publicación se eliminará permanentemente.';

  @override
  String get post_delete_confirmation => '¿Eliminar publicación?';

  @override
  String get post_delete_confirmation_description => '¿Quieres eliminar tu publicación?';

  @override
  String get post_report => 'Reportar publicación';

  @override
  String get post_unreport => 'Desreportar publicación';

  @override
  String get post_like => 'Me gusta';

  @override
  String get post_comment => 'Comentar';

  @override
  String get post_share => 'Compartir';

  @override
  String get post_discard => '¿Descartar esta publicación?';

  @override
  String get post_discard_description => 'La publicación se eliminará permanentemente. No se puede deshacer.';

  @override
  String get post_write_comment => 'Escribe un comentario...';

  @override
  String get poll_duration => 'Duración de la encuesta';

  @override
  String get poll_duration_hint => 'Siempre puedes cerrar la encuesta antes de la duración establecida.';

  @override
  String get poll_custom_edn_date => 'Fecha de finalización personalizada';

  @override
  String get poll_close => 'Cerrar encuesta';

  @override
  String get poll_close_description => 'Esta encuesta está cerrada. Ya no puedes votar.';

  @override
  String get poll_vote => 'Votar';

  @override
  String get poll_results => 'Ver resultados';

  @override
  String get poll_back_to_vote => 'Volver a votar';

  @override
  String poll_vote_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String poll_total_votes(int count, String plusSign) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Votado por $count$plusSign participantes',
      one: 'Votado por 1 participante',
      zero: 'Sin votos',
    );
    return '$_temp0';
  }

  @override
  String poll_see_more_options(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count opciones más',
      one: 'Ver 1 opción más',
    );
    return '$_temp0';
  }

  @override
  String get poll_see_full_results => 'Ver resultados completos';

  @override
  String get poll_voted => 'Votado por ti';

  @override
  String get poll_and_you => ' y tú';

  @override
  String get poll_remaining_time => 'restante';

  @override
  String get poll_vote_error => 'Error al votar en la encuesta. Por favor, inténtalo de nuevo.';

  @override
  String get poll_ended => 'Finalizado';

  @override
  String get poll_single_choice => 'Selecciona una opción';

  @override
  String get poll_multiple_choice => 'Selecciona una o más opciones';

  @override
  String poll_options_description(int minOptions) {
    return 'La encuesta debe contener al menos $minOptions opciones.';
  }

  @override
  String get poll_question => 'Pregunta de la encuesta';

  @override
  String get poll_question_hint => '¿Cuál es tu pregunta de la encuesta?';

  @override
  String get comment_create_hint => 'Di algo agradable...';

  @override
  String get comment_reply => 'Responder';

  @override
  String get comment_reply_to => 'Respondiendo a ';

  @override
  String comment_view_reply_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count respuestas',
      one: 'Ver 1 respuesta',
    );
    return '$_temp0';
  }

  @override
  String get comment_report => 'Reportar comentario';

  @override
  String get comment_unreport => 'Desreportar comentario';

  @override
  String get comment_reply_report => 'Reportar respuesta';

  @override
  String get comment_reply_unreport => 'Desreportar respuesta';

  @override
  String get comment_edit => 'Editar comentario';

  @override
  String get comment_reply_edit => 'Editar respuesta';

  @override
  String get comment_delete => 'Eliminar comentario';

  @override
  String get comment_reply_delete => 'Eliminar respuesta';

  @override
  String comment_delete_description(String content) {
    return 'Este $content se eliminará permanentemente.';
  }

  @override
  String get community_close => '¿Cerrar comunidad?';

  @override
  String get community_close_description => 'Todos los miembros serán eliminados de la comunidad. Todas las publicaciones, mensajes, reacciones y medios compartidos en la comunidad serán eliminados. Esto no se puede deshacer.';

  @override
  String get community_join => 'Unirse';

  @override
  String get community_joined => 'Unido';

  @override
  String get community_recommended_for_you => 'Recomendado para ti';

  @override
  String get community_trending_now => 'Tendencia ahora';

  @override
  String get community_placeholder_members => '1.2K miembros';

  @override
  String get community_leave => 'Dejar comunidad';

  @override
  String get community_leave_description => 'Deja la comunidad. Ya no podrás publicar e interactuar en esta comunidad.';

  @override
  String get community_create => 'Crear comunidad';

  @override
  String get community_name => 'Nombre de la comunidad';

  @override
  String get community_name_hint => 'Nombra tu comunidad';

  @override
  String get community_description_hint => 'Ingresa una descripción';

  @override
  String get community_edit => 'Editar comunidad';

  @override
  String get community_members => 'Miembros';

  @override
  String get community_private => 'Privado';

  @override
  String get community_public => 'Público';

  @override
  String get community_public_description => 'Cualquiera puede unirse, ver y buscar las publicaciones en esta comunidad.';

  @override
  String get community_private_description => 'Solo los miembros invitados por los moderadores pueden unirse, ver y buscar las publicaciones en esta comunidad.';

  @override
  String get community_about => 'Acerca de';

  @override
  String get categories_title => 'Categorías';

  @override
  String get category_hint => 'Seleccionar categoría';

  @override
  String get category_select_title => 'Seleccionar Categoría';

  @override
  String get category_add => 'Agregar Categoría';

  @override
  String get community_pending_posts => 'Publicaciones pendientes';

  @override
  String get commnuity_pending_post_reviewing => 'Tus publicaciones están pendientes de revisión';

  @override
  String commnuity_pending_post_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones necesitan aprobación',
      one: '$count publicación necesita aprobación',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Solicitudes pendientes',
      one: 'Solicitud pendiente',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_message(String displayCount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicaciones requieren',
      one: 'publicación requiere',
    );
    return '$displayCount $_temp0 aprobación';
  }

  @override
  String get community_basic_info => 'Información básica';

  @override
  String get community_discard_confirmation => '¿Salir sin terminar?';

  @override
  String get community_discard_description => 'Tu progreso no se guardará y tu comunidad no se creará.';

  @override
  String get message_send => 'Enviar';

  @override
  String get message_typing => 'está escribiendo...';

  @override
  String get message_placeholder => 'Escribe un mensaje...';

  @override
  String get settings_title => 'Configuraciones';

  @override
  String get settings_notifications => 'Notificaciones';

  @override
  String get settings_new_posts => 'Nuevas publicaciones';

  @override
  String get settings_new_posts_description => 'Recibe notificaciones cuando alguien cree nuevas publicaciones en esta comunidad.';

  @override
  String get settings_react_posts => 'Reaccionar a publicaciones';

  @override
  String get settings_react_posts_description => 'Recibe notificaciones cuando alguien reaccione a tus publicaciones en esta comunidad.';

  @override
  String get settings_react_comments => 'Reaccionar a comentarios';

  @override
  String get settings_react_comments_description => 'Recibe notificaciones cuando alguien le guste tu comentario en esta comunidad.';

  @override
  String get settings_new_comments => 'Nuevos comentarios';

  @override
  String get settings_new_comments_description => 'Recibe notificaciones cuando alguien comente en tu publicación en esta comunidad.';

  @override
  String get settings_new_replies => 'Respuestas';

  @override
  String get settings_new_replies_description => 'Recibe notificaciones cuando alguien comente en tus comentarios en esta comunidad.';

  @override
  String get settings_allow_stories_comments => 'Permitir comentarios en historias de la comunidad';

  @override
  String get settings_allow_stories_comments_description => 'Activa para recibir comentarios en historias en esta comunidad.';

  @override
  String get settings_new_stories => 'Nuevas historias';

  @override
  String get settings_new_stories_description => 'Recibe notificaciones cuando alguien cree una nueva historia en esta comunidad.';

  @override
  String get settings_story_reactions => 'Reacciones a historias';

  @override
  String get settings_story_reactions_description => 'Recibe notificaciones cuando alguien reaccione a tu historia en esta comunidad.';

  @override
  String get settings_story_comments => 'Comentarios en historias';

  @override
  String get settings_story_comments_description => 'Recibe notificaciones cuando alguien comente en tu historia en esta comunidad.';

  @override
  String get settings_everyone => 'Todos';

  @override
  String get settings_only_moderators => 'Solo moderadores';

  @override
  String get settings_only_admins => 'Solo los administradores pueden publicar';

  @override
  String get settings_privacy => 'Privacidad';

  @override
  String get settings_permissions => 'Permisos de la comunidad';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_leave_confirmation => '¿Salir sin terminar?';

  @override
  String get settings_leave_description => 'Es posible que los cambios que realizaste no se guarden.';

  @override
  String get settings_privacy_confirmation => '¿Cambiar la configuración de privacidad de la comunidad?';

  @override
  String get settings_privacy_description => 'Esta comunidad tiene publicaciones destacadas a nivel mundial. Cambiar la comunidad de pública a privada eliminará estas publicaciones de ser destacadas a nivel mundial.';

  @override
  String get general_add => 'Agregar';

  @override
  String get general_loading => 'Cargando...';

  @override
  String get general_leave => 'Salir';

  @override
  String get general_error => 'Ups, algo salió mal';

  @override
  String get general_edited => 'Editado';

  @override
  String get general_edited_suffix => ' (editado)';

  @override
  String get general_keep_editing => 'Seguir editando';

  @override
  String get general_discard => 'Descartar';

  @override
  String get general_moderator => 'Moderador';

  @override
  String get general_save => 'Guardar';

  @override
  String get general_delete => 'Eliminar';

  @override
  String get general_edit => 'Editar';

  @override
  String get general_close => 'Cerrar';

  @override
  String get general_done => 'Hecho';

  @override
  String get general_post => 'Publicar';

  @override
  String get general_comments => 'Comentarios';

  @override
  String get general_story => 'Historia';

  @override
  String get general_stories => 'Historias';

  @override
  String get general_poll => 'Encuesta';

  @override
  String get general_optional => 'Opcional';

  @override
  String get general_on => 'Encendido';

  @override
  String get general_off => 'Apagado';

  @override
  String get settings_allow_notification => 'Permitir Notificaciones';

  @override
  String get settings_allow_notification_description => 'Activa para recibir notificaciones push de esta comunidad.';

  @override
  String get general_reported => 'reportado';

  @override
  String get general_unreported => 'no reportado';

  @override
  String get general_see_more => '...Ver más';

  @override
  String get general_camera => 'Cámara';

  @override
  String get general_photo => 'Foto';

  @override
  String get general_video => 'Video';

  @override
  String get general_posting => 'Publicando';

  @override
  String get general_my_timeline => 'Mi cronología';

  @override
  String get general_options => 'Opciones';

  @override
  String get post_edit_globally_featured => '¿Editar publicación destacada a nivel mundial?';

  @override
  String get post_edit_globally_featured_description => 'La publicación que estás editando ha sido destacada a nivel mundial. Si editas tu publicación, necesitará ser aprobada nuevamente y ya no será destacada a nivel mundial.';

  @override
  String post_like_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '1 me gusta',
    );
    return '$_temp0';
  }

  @override
  String post_comment_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentarios',
      one: '1 comentario',
    );
    return '$_temp0';
  }

  @override
  String get post_reported => 'Publicación reportada.';

  @override
  String get post_unreported => 'Publicación desreportada.';

  @override
  String profile_followers_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seguidores',
      one: '1 seguidor',
      zero: 'Sin seguidores',
    );
    return '$_temp0';
  }

  @override
  String community_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
      zero: 'Sin miembros',
    );
    return '$_temp0';
  }

  @override
  String profile_posts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicaciones',
      one: 'publicación',
    );
    return '$_temp0';
  }

  @override
  String profile_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'miembros',
      one: 'miembro',
    );
    return '$_temp0';
  }

  @override
  String get user_block => 'Bloquear Usuario';

  @override
  String get user_unblock => 'Desbloquear usuario';

  @override
  String get error_delete_post => 'Error al eliminar la publicación. Por favor, inténtalo de nuevo.';

  @override
  String get error_leave_community => 'No se puede dejar la comunidad';

  @override
  String get error_leave_community_description => 'Eres el único moderador en este grupo. Para dejar la comunidad, nombra a otros miembros como moderadores';

  @override
  String get error_close_community => 'No se puede cerrar la comunidad';

  @override
  String get error_close_community_description => 'Algo salió mal. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get error_max_upload_reached => 'Se alcanzó el límite máximo de carga';

  @override
  String error_max_upload_image_reached_description(int maxUploads) {
    return 'Has alcanzado el límite de carga de $maxUploads imágenes. Las imágenes adicionales no se guardarán.';
  }

  @override
  String error_max_upload_videos_reached_description(int maxUploads) {
    return 'Has alcanzado el límite de carga de $maxUploads videos. Los videos adicionales no se guardarán.';
  }

  @override
  String get error_edit_post => 'Error al editar la publicación. Por favor, inténtalo de nuevo.';

  @override
  String get error_create_post => 'Error al crear la publicación. Por favor, inténtalo de nuevo.';

  @override
  String error_max_poll_characters(int maxQuestionLength) {
    return 'La pregunta de la encuesta no puede exceder los $maxQuestionLength caracteres.';
  }

  @override
  String error_max_poll_option_characters(int maxQuestionLength) {
    return 'La opción de la encuesta no puede exceder los $maxQuestionLength caracteres.';
  }

  @override
  String get error_create_poll => 'Error al crear la encuesta. Por favor, inténtalo de nuevo.';

  @override
  String get user_profile_unknown_name => 'Desconocido';

  @override
  String get community_all_members => 'Todos los miembros';

  @override
  String get community_moderators => 'Moderadores';

  @override
  String get community_search_member_hint => 'Buscar miembro';

  @override
  String get community_promote_moderator => 'Promover a moderador';

  @override
  String get community_demote_member => 'Degradar a miembro';

  @override
  String get community_remove_member => 'Eliminar de la comunidad';

  @override
  String get user_report => 'Reportar usuario';

  @override
  String get user_unreport => 'Desreportar usuario';

  @override
  String get feed_no_videos => 'Aún no hay videos';

  @override
  String get feed_no_photos => 'Aún no hay fotos';

  @override
  String get feed_no_pinned_posts => 'Aún no hay publicaciones fijadas';

  @override
  String get feed_no_posts => 'Aún no hay publicaciones';

  @override
  String get member_add => 'Agregar miembro';

  @override
  String get search_user_hint => 'Buscar usuario';

  @override
  String get profile_edit => 'Editar perfil';

  @override
  String get profile_update_success => '¡Perfil actualizado exitosamente!';

  @override
  String get profile_update_failed => 'Error al guardar tu perfil. Por favor, inténtalo de nuevo.';
}

/// The translations for Spanish Castilian, as used in Colombia (`es_CO`).
class AppLocalizationsEsCo extends AppLocalizationsEs {
  AppLocalizationsEsCo(): super('es_CO');

  @override
  String get community_title => 'Comunidad';

  @override
  String get tab_newsfeed => 'Noticias';

  @override
  String get tab_explore => 'Explorar';

  @override
  String get tab_my_communities => 'Mis Comunidades';

  @override
  String get global_search_hint => 'Buscar comunidad y usuario';

  @override
  String get search_my_community_hint => 'Buscar mi comunidad';

  @override
  String get search_no_results => 'No se encontraron resultados';

  @override
  String get title_communities => 'Comunidades';

  @override
  String get title_users => 'Usuarios';

  @override
  String get general_cancel => 'Cancelar';

  @override
  String get general_ok => 'OK';

  @override
  String get general_confirm => 'Confirmar';

  @override
  String get general_featured => 'Destacado';

  @override
  String get profile_followers => 'Seguidores';

  @override
  String get profile_following => 'Siguiendo';

  @override
  String get profile_posts => 'Publicaciones';

  @override
  String get post_create => 'Crear publicación';

  @override
  String get post_edit => 'Editar publicación';

  @override
  String get post_create_hint => '¿Qué está pasando...?';

  @override
  String get post_delete => 'Eliminar publicación';

  @override
  String get post_delete_description => 'Esta publicación se eliminará permanentemente.';

  @override
  String get post_delete_confirmation => '¿Eliminar publicación?';

  @override
  String get post_delete_confirmation_description => '¿Quieres eliminar tu publicación?';

  @override
  String get post_report => 'Reportar publicación';

  @override
  String get post_unreport => 'Desreportar publicación';

  @override
  String get post_like => 'Me gusta';

  @override
  String get post_comment => 'Comentar';

  @override
  String get post_share => 'Compartir';

  @override
  String get post_discard => '¿Descartar esta publicación?';

  @override
  String get post_discard_description => 'La publicación se eliminará permanentemente. No se puede deshacer.';

  @override
  String get post_write_comment => 'Escribe un comentario...';

  @override
  String get poll_duration => 'Duración de la encuesta';

  @override
  String get poll_duration_hint => 'Siempre puedes cerrar la encuesta antes de la duración establecida.';

  @override
  String get poll_custom_edn_date => 'Fecha de finalización personalizada';

  @override
  String get poll_close => 'Cerrar encuesta';

  @override
  String get poll_close_description => 'Esta encuesta está cerrada. Ya no puedes votar.';

  @override
  String get poll_vote => 'Votar';

  @override
  String get poll_results => 'Ver resultados';

  @override
  String get poll_back_to_vote => 'Volver a votar';

  @override
  String poll_vote_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String poll_total_votes(int count, String plusSign) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Votado por $count$plusSign participantes',
      one: 'Votado por 1 participante',
      zero: 'Sin votos',
    );
    return '$_temp0';
  }

  @override
  String poll_see_more_options(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count opciones más',
      one: 'Ver 1 opción más',
    );
    return '$_temp0';
  }

  @override
  String get poll_see_full_results => 'Ver resultados completos';

  @override
  String get poll_voted => 'Votado por ti';

  @override
  String get poll_and_you => ' y tú';

  @override
  String get poll_remaining_time => 'restante';

  @override
  String get poll_vote_error => 'Error al votar en la encuesta. Por favor, inténtalo de nuevo.';

  @override
  String get poll_ended => 'Finalizado';

  @override
  String get poll_single_choice => 'Selecciona una opción';

  @override
  String get poll_multiple_choice => 'Selecciona una o más opciones';

  @override
  String poll_options_description(int minOptions) {
    return 'La encuesta debe contener al menos $minOptions opciones.';
  }

  @override
  String get poll_question => 'Pregunta de la encuesta';

  @override
  String get poll_question_hint => '¿Cuál es tu pregunta de la encuesta?';

  @override
  String get comment_create_hint => 'Di algo agradable...';

  @override
  String get comment_reply => 'Responder';

  @override
  String get comment_reply_to => 'Respondiendo a ';

  @override
  String comment_view_reply_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count respuestas',
      one: 'Ver 1 respuesta',
    );
    return '$_temp0';
  }

  @override
  String get comment_report => 'Reportar comentario';

  @override
  String get comment_unreport => 'Desreportar comentario';

  @override
  String get comment_reply_report => 'Reportar respuesta';

  @override
  String get comment_reply_unreport => 'Desreportar respuesta';

  @override
  String get comment_edit => 'Editar comentario';

  @override
  String get comment_reply_edit => 'Editar respuesta';

  @override
  String get comment_delete => 'Eliminar comentario';

  @override
  String get comment_reply_delete => 'Eliminar respuesta';

  @override
  String comment_delete_description(String content) {
    return 'Este $content se eliminará permanentemente.';
  }

  @override
  String get community_close => '¿Cerrar comunidad?';

  @override
  String get community_close_description => 'Todos los miembros serán eliminados de la comunidad. Todas las publicaciones, mensajes, reacciones y medios compartidos en la comunidad serán eliminados. Esto no se puede deshacer.';

  @override
  String get community_join => 'Unirse';

  @override
  String get community_joined => 'Unido';

  @override
  String get community_recommended_for_you => 'Recomendado para ti';

  @override
  String get community_trending_now => 'En tendencia';

  @override
  String get community_placeholder_members => '1.2K miembros';

  @override
  String get community_leave => 'Dejar comunidad';

  @override
  String get community_leave_description => 'Deja la comunidad. Ya no podrás publicar e interactuar en esta comunidad.';

  @override
  String get community_create => 'Crear comunidad';

  @override
  String get community_name => 'Nombre de la comunidad';

  @override
  String get community_name_hint => 'Nombra tu comunidad';

  @override
  String get community_description_hint => 'Ingresa una descripción';

  @override
  String get community_edit => 'Editar comunidad';

  @override
  String get community_members => 'Miembros';

  @override
  String get community_private => 'Privado';

  @override
  String get community_public => 'Público';

  @override
  String get community_public_description => 'Cualquiera puede unirse, ver y buscar las publicaciones en esta comunidad.';

  @override
  String get community_private_description => 'Solo los miembros invitados por los moderadores pueden unirse, ver y buscar las publicaciones en esta comunidad.';

  @override
  String get community_about => 'Acerca de';

  @override
  String get categories_title => 'Categorías';

  @override
  String get category_hint => 'Seleccionar categoría';

  @override
  String get category_select_title => 'Seleccionar Categoría';

  @override
  String get category_add => 'Agregar Categoría';

  @override
  String get community_pending_posts => 'Publicaciones pendientes';

  @override
  String get commnuity_pending_post_reviewing => 'Tus publicaciones están pendientes de revisión';

  @override
  String commnuity_pending_post_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones necesitan aprobación',
      one: '$count publicación necesita aprobación',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Solicitudes pendientes',
      one: 'Solicitud pendiente',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_message(String displayCount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicaciones requieren',
      one: 'publicación requiere',
    );
    return '$displayCount $_temp0 aprobación';
  }

  @override
  String get community_basic_info => 'Información básica';

  @override
  String get community_discard_confirmation => '¿Salir sin terminar?';

  @override
  String get community_discard_description => 'Tu progreso no se guardará y tu comunidad no se creará.';

  @override
  String get message_send => 'Enviar';

  @override
  String get message_typing => 'está escribiendo...';

  @override
  String get message_placeholder => 'Escribe un mensaje...';

  @override
  String get settings_title => 'Configuraciones';

  @override
  String get settings_notifications => 'Notificaciones';

  @override
  String get settings_new_posts => 'Nuevas publicaciones';

  @override
  String get settings_new_posts_description => 'Recibe notificaciones cuando alguien cree nuevas publicaciones en esta comunidad.';

  @override
  String get settings_react_posts => 'Reaccionar a publicaciones';

  @override
  String get settings_react_posts_description => 'Recibe notificaciones cuando alguien reaccione a tus publicaciones en esta comunidad.';

  @override
  String get settings_react_comments => 'Reaccionar a comentarios';

  @override
  String get settings_react_comments_description => 'Recibe notificaciones cuando alguien le guste tu comentario en esta comunidad.';

  @override
  String get settings_new_comments => 'Nuevos comentarios';

  @override
  String get settings_new_comments_description => 'Recibe notificaciones cuando alguien comente en tu publicación en esta comunidad.';

  @override
  String get settings_new_replies => 'Respuestas';

  @override
  String get settings_new_replies_description => 'Recibe notificaciones cuando alguien comente en tus comentarios en esta comunidad.';

  @override
  String get settings_allow_stories_comments => 'Permitir comentarios en historias de la comunidad';

  @override
  String get settings_allow_stories_comments_description => 'Activa para recibir comentarios en historias en esta comunidad.';

  @override
  String get settings_new_stories => 'Nuevas historias';

  @override
  String get settings_new_stories_description => 'Recibe notificaciones cuando alguien cree una nueva historia en esta comunidad.';

  @override
  String get settings_story_reactions => 'Reacciones a historias';

  @override
  String get settings_story_reactions_description => 'Recibe notificaciones cuando alguien reaccione a tu historia en esta comunidad.';

  @override
  String get settings_story_comments => 'Comentarios en historias';

  @override
  String get settings_story_comments_description => 'Recibe notificaciones cuando alguien comente en tu historia en esta comunidad.';

  @override
  String get settings_everyone => 'Todos';

  @override
  String get settings_only_moderators => 'Solo moderadores';

  @override
  String get settings_only_admins => 'Solo los administradores pueden publicar';

  @override
  String get settings_privacy => 'Privacidad';

  @override
  String get settings_permissions => 'Permisos de la comunidad';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_leave_confirmation => '¿Salir sin terminar?';

  @override
  String get settings_leave_description => 'Los cambios que realizaste pueden no guardarse.';

  @override
  String get settings_privacy_confirmation => '¿Cambiar la configuración de privacidad de la comunidad?';

  @override
  String get settings_privacy_description => 'Esta comunidad tiene publicaciones destacadas a nivel mundial. Cambiar la comunidad de pública a privada eliminará estas publicaciones de ser destacadas a nivel mundial.';

  @override
  String get general_add => 'Agregar';

  @override
  String get general_loading => 'Cargando...';

  @override
  String get general_leave => 'Salir';

  @override
  String get general_error => 'Ups, algo salió mal';

  @override
  String get general_edited => 'Editado';

  @override
  String get general_edited_suffix => ' (editado)';

  @override
  String get general_keep_editing => 'Seguir editando';

  @override
  String get general_discard => 'Descartar';

  @override
  String get general_moderator => 'Moderador';

  @override
  String get general_save => 'Guardar';

  @override
  String get general_delete => 'Eliminar';

  @override
  String get general_edit => 'Editar';

  @override
  String get general_close => 'Cerrar';

  @override
  String get general_done => 'Hecho';

  @override
  String get general_post => 'Publicar';

  @override
  String get general_comments => 'Comentarios';

  @override
  String get general_story => 'Historia';

  @override
  String get general_stories => 'Historias';

  @override
  String get general_poll => 'Encuesta';

  @override
  String get general_optional => 'Opcional';

  @override
  String get general_on => 'Encendido';

  @override
  String get general_off => 'Apagado';

  @override
  String get settings_allow_notification => 'Permitir Notificaciones';

  @override
  String get settings_allow_notification_description => 'Activa para recibir notificaciones push de esta comunidad.';

  @override
  String get general_reported => 'reportado';

  @override
  String get general_unreported => 'no reportado';

  @override
  String get general_see_more => '...Ver más';

  @override
  String get general_camera => 'Cámara';

  @override
  String get general_photo => 'Foto';

  @override
  String get general_video => 'Video';

  @override
  String get general_posting => 'Publicando';

  @override
  String get general_my_timeline => 'Mi cronología';

  @override
  String get general_options => 'Opciones';

  @override
  String get post_edit_globally_featured => '¿Editar publicación destacada a nivel mundial?';

  @override
  String get post_edit_globally_featured_description => 'La publicación que estás editando ha sido destacada a nivel mundial. Si editas tu publicación, necesitará ser aprobada nuevamente y ya no será destacada a nivel mundial.';

  @override
  String post_like_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '1 me gusta',
    );
    return '$_temp0';
  }

  @override
  String post_comment_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentarios',
      one: '1 comentario',
    );
    return '$_temp0';
  }

  @override
  String get post_reported => 'Publicación reportada.';

  @override
  String get post_unreported => 'Publicación desreportada.';

  @override
  String profile_followers_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seguidores',
      one: '1 seguidor',
      zero: 'Sin seguidores',
    );
    return '$_temp0';
  }

  @override
  String community_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
      zero: 'Sin miembros',
    );
    return '$_temp0';
  }

  @override
  String profile_posts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicaciones',
      one: 'publicación',
    );
    return '$_temp0';
  }

  @override
  String profile_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'miembros',
      one: 'miembro',
    );
    return '$_temp0';
  }

  @override
  String get user_block => 'Bloquear Usuario';

  @override
  String get user_unblock => 'Desbloquear usuario';

  @override
  String get error_delete_post => 'Error al eliminar la publicación. Por favor, inténtalo de nuevo.';

  @override
  String get error_leave_community => 'No se puede dejar la comunidad';

  @override
  String get error_leave_community_description => 'Eres el único moderador en este grupo. Para dejar la comunidad, nombra a otros miembros como moderadores';

  @override
  String get error_close_community => 'No se puede cerrar la comunidad';

  @override
  String get error_close_community_description => 'Algo salió mal. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get error_max_upload_reached => 'Límite máximo de carga alcanzado';

  @override
  String error_max_upload_image_reached_description(int maxUploads) {
    return 'Has alcanzado el límite de carga de $maxUploads imágenes. Las imágenes adicionales no se guardarán.';
  }

  @override
  String error_max_upload_videos_reached_description(int maxUploads) {
    return 'Has alcanzado el límite de carga de $maxUploads videos. Los videos adicionales no se guardarán.';
  }

  @override
  String get error_edit_post => 'Error al editar la publicación. Por favor, inténtalo de nuevo.';

  @override
  String get error_create_post => 'Error al crear la publicación. Por favor, inténtalo de nuevo.';

  @override
  String error_max_poll_characters(int maxQuestionLength) {
    return 'La pregunta de la encuesta no puede exceder los $maxQuestionLength caracteres.';
  }

  @override
  String error_max_poll_option_characters(int maxQuestionLength) {
    return 'La opción de la encuesta no puede exceder los $maxQuestionLength caracteres.';
  }

  @override
  String get error_create_poll => 'Error al crear la encuesta. Por favor, inténtalo de nuevo.';

  @override
  String get user_profile_unknown_name => 'Desconocido';

  @override
  String get community_all_members => 'Todos los miembros';

  @override
  String get community_moderators => 'Moderadores';

  @override
  String get community_search_member_hint => 'Buscar miembro';

  @override
  String get community_promote_moderator => 'Promover a moderador';

  @override
  String get community_demote_member => 'Degradar a miembro';

  @override
  String get community_remove_member => 'Eliminar de la comunidad';

  @override
  String get user_report => 'Reportar usuario';

  @override
  String get user_unreport => 'Desreportar usuario';

  @override
  String get feed_no_videos => 'Aún no hay videos';

  @override
  String get feed_no_photos => 'Aún no hay fotos';

  @override
  String get feed_no_pinned_posts => 'Aún no hay publicaciones fijadas';

  @override
  String get feed_no_posts => 'Aún no hay publicaciones';

  @override
  String get member_add => 'Agregar miembro';

  @override
  String get search_user_hint => 'Buscar usuario';

  @override
  String get profile_edit => 'Editar perfil';

  @override
  String get profile_update_success => '¡Perfil actualizado con éxito!';

  @override
  String get profile_update_failed => 'Error al guardar tu perfil. Por favor, inténtalo de nuevo.';
}

/// The translations for Spanish Castilian, as used in Mexico (`es_MX`).
class AppLocalizationsEsMx extends AppLocalizationsEs {
  AppLocalizationsEsMx(): super('es_MX');

  @override
  String get community_title => 'Comunidad';

  @override
  String get tab_newsfeed => 'Noticias';

  @override
  String get tab_explore => 'Explorar';

  @override
  String get tab_my_communities => 'Mis Comunidades';

  @override
  String get global_search_hint => 'Buscar comunidad y usuario';

  @override
  String get search_my_community_hint => 'Buscar mi comunidad';

  @override
  String get search_no_results => 'No se encontraron resultados';

  @override
  String get title_communities => 'Comunidades';

  @override
  String get title_users => 'Usuarios';

  @override
  String get general_cancel => 'Cancelar';

  @override
  String get general_ok => 'OK';

  @override
  String get general_confirm => 'Confirmar';

  @override
  String get general_featured => 'Destacado';

  @override
  String get profile_followers => 'Seguidores';

  @override
  String get profile_following => 'Siguiendo';

  @override
  String get profile_posts => 'Publicaciones';

  @override
  String get post_create => 'Crear publicación';

  @override
  String get post_edit => 'Editar publicación';

  @override
  String get post_create_hint => '¿Qué está pasando...?';

  @override
  String get post_delete => 'Eliminar publicación';

  @override
  String get post_delete_description => 'Esta publicación se eliminará permanentemente.';

  @override
  String get post_delete_confirmation => '¿Eliminar publicación?';

  @override
  String get post_delete_confirmation_description => '¿Quieres eliminar tu publicación?';

  @override
  String get post_report => 'Reportar publicación';

  @override
  String get post_unreport => 'Desreportar publicación';

  @override
  String get post_like => 'Me gusta';

  @override
  String get post_comment => 'Comentar';

  @override
  String get post_share => 'Compartir';

  @override
  String get post_discard => '¿Descartar esta publicación?';

  @override
  String get post_discard_description => 'La publicación se eliminará permanentemente. No se puede deshacer.';

  @override
  String get post_write_comment => 'Escribe un comentario...';

  @override
  String get poll_duration => 'Duración de la encuesta';

  @override
  String get poll_duration_hint => 'Siempre puedes cerrar la encuesta antes de la duración establecida.';

  @override
  String get poll_custom_edn_date => 'Fecha de finalización personalizada';

  @override
  String get poll_close => 'Cerrar encuesta';

  @override
  String get poll_close_description => 'Esta encuesta está cerrada. Ya no puedes votar.';

  @override
  String get poll_vote => 'Votar';

  @override
  String get poll_results => 'Ver resultados';

  @override
  String get poll_back_to_vote => 'Volver a votar';

  @override
  String poll_vote_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String poll_total_votes(int count, String plusSign) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Votado por $count$plusSign participantes',
      one: 'Votado por 1 participante',
      zero: 'Sin votos',
    );
    return '$_temp0';
  }

  @override
  String poll_see_more_options(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count opciones más',
      one: 'Ver 1 opción más',
    );
    return '$_temp0';
  }

  @override
  String get poll_see_full_results => 'Ver resultados completos';

  @override
  String get poll_voted => 'Votado por ti';

  @override
  String get poll_and_you => ' y tú';

  @override
  String get poll_remaining_time => 'restante';

  @override
  String get poll_vote_error => 'Error al votar en la encuesta. Por favor, inténtalo de nuevo.';

  @override
  String get poll_ended => 'Finalizado';

  @override
  String get poll_single_choice => 'Selecciona una opción';

  @override
  String get poll_multiple_choice => 'Selecciona una o más opciones';

  @override
  String poll_options_description(int minOptions) {
    return 'La encuesta debe contener al menos $minOptions opciones.';
  }

  @override
  String get poll_question => 'Pregunta de la encuesta';

  @override
  String get poll_question_hint => '¿Cuál es tu pregunta de la encuesta?';

  @override
  String get comment_create_hint => 'Di algo agradable...';

  @override
  String get comment_reply => 'Responder';

  @override
  String get comment_reply_to => 'Respondiendo a ';

  @override
  String comment_view_reply_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count respuestas',
      one: 'Ver 1 respuesta',
    );
    return '$_temp0';
  }

  @override
  String get comment_report => 'Reportar comentario';

  @override
  String get comment_unreport => 'Desreportar comentario';

  @override
  String get comment_reply_report => 'Reportar respuesta';

  @override
  String get comment_reply_unreport => 'Desreportar respuesta';

  @override
  String get comment_edit => 'Editar comentario';

  @override
  String get comment_reply_edit => 'Editar respuesta';

  @override
  String get comment_delete => 'Eliminar comentario';

  @override
  String get comment_reply_delete => 'Eliminar respuesta';

  @override
  String comment_delete_description(String content) {
    return 'Este $content se eliminará permanentemente.';
  }

  @override
  String get community_close => '¿Cerrar comunidad?';

  @override
  String get community_close_description => 'Todos los miembros serán eliminados de la comunidad. Todas las publicaciones, mensajes, reacciones y medios compartidos en la comunidad serán eliminados. Esto no se puede deshacer.';

  @override
  String get community_join => 'Unirse';

  @override
  String get community_joined => 'Unido';

  @override
  String get community_recommended_for_you => 'Recomendado para ti';

  @override
  String get community_trending_now => 'Popular ahora';

  @override
  String get community_placeholder_members => '1.2K miembros';

  @override
  String get community_leave => 'Dejar comunidad';

  @override
  String get community_leave_description => 'Dejar la comunidad. Ya no podrás publicar e interactuar en esta comunidad.';

  @override
  String get community_create => 'Crear comunidad';

  @override
  String get community_name => 'Nombre de la comunidad';

  @override
  String get community_name_hint => 'Nombra tu comunidad';

  @override
  String get community_description_hint => 'Ingresa una descripción';

  @override
  String get community_edit => 'Editar comunidad';

  @override
  String get community_members => 'Miembros';

  @override
  String get community_private => 'Privado';

  @override
  String get community_public => 'Público';

  @override
  String get community_public_description => 'Cualquiera puede unirse, ver y buscar las publicaciones en esta comunidad.';

  @override
  String get community_private_description => 'Solo los miembros invitados por los moderadores pueden unirse, ver y buscar las publicaciones en esta comunidad.';

  @override
  String get community_about => 'Acerca de';

  @override
  String get categories_title => 'Categorías';

  @override
  String get category_hint => 'Seleccionar categoría';

  @override
  String get category_select_title => 'Seleccionar Categoría';

  @override
  String get category_add => 'Añadir Categoría';

  @override
  String get community_pending_posts => 'Publicaciones pendientes';

  @override
  String get commnuity_pending_post_reviewing => 'Tus publicaciones están pendientes de revisión';

  @override
  String commnuity_pending_post_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones necesitan aprobación',
      one: '$count publicación necesita aprobación',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Solicitudes pendientes',
      one: 'Solicitud pendiente',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_message(String displayCount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicaciones requieren',
      one: 'publicación requiere',
    );
    return '$displayCount $_temp0 aprobación';
  }

  @override
  String get community_basic_info => 'Información básica';

  @override
  String get community_discard_confirmation => '¿Salir sin terminar?';

  @override
  String get community_discard_description => 'Tu progreso no se guardará y tu comunidad no se creará.';

  @override
  String get message_send => 'Enviar';

  @override
  String get message_typing => 'está escribiendo...';

  @override
  String get message_placeholder => 'Escribe un mensaje...';

  @override
  String get settings_title => 'Configuraciones';

  @override
  String get settings_notifications => 'Notificaciones';

  @override
  String get settings_new_posts => 'Nuevas publicaciones';

  @override
  String get settings_new_posts_description => 'Recibe notificaciones cuando alguien cree nuevas publicaciones en esta comunidad.';

  @override
  String get settings_react_posts => 'Reaccionar a publicaciones';

  @override
  String get settings_react_posts_description => 'Recibe notificaciones cuando alguien reaccione a tus publicaciones en esta comunidad.';

  @override
  String get settings_react_comments => 'Reaccionar a comentarios';

  @override
  String get settings_react_comments_description => 'Recibe notificaciones cuando alguien le guste tu comentario en esta comunidad.';

  @override
  String get settings_new_comments => 'Nuevos comentarios';

  @override
  String get settings_new_comments_description => 'Recibe notificaciones cuando alguien comente en tu publicación en esta comunidad.';

  @override
  String get settings_new_replies => 'Respuestas';

  @override
  String get settings_new_replies_description => 'Recibe notificaciones cuando alguien comente en tus comentarios en esta comunidad.';

  @override
  String get settings_allow_stories_comments => 'Permitir comentarios en historias de la comunidad';

  @override
  String get settings_allow_stories_comments_description => 'Activa para recibir comentarios en historias en esta comunidad.';

  @override
  String get settings_new_stories => 'Nuevas historias';

  @override
  String get settings_new_stories_description => 'Recibe notificaciones cuando alguien cree una nueva historia en esta comunidad.';

  @override
  String get settings_story_reactions => 'Reacciones a historias';

  @override
  String get settings_story_reactions_description => 'Recibe notificaciones cuando alguien reaccione a tu historia en esta comunidad.';

  @override
  String get settings_story_comments => 'Comentarios en historias';

  @override
  String get settings_story_comments_description => 'Recibe notificaciones cuando alguien comente en tu historia en esta comunidad.';

  @override
  String get settings_everyone => 'Todos';

  @override
  String get settings_only_moderators => 'Solo moderadores';

  @override
  String get settings_only_admins => 'Solo los administradores pueden publicar';

  @override
  String get settings_privacy => 'Privacidad';

  @override
  String get settings_permissions => 'Permisos de la comunidad';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_leave_confirmation => '¿Salir sin terminar?';

  @override
  String get settings_leave_description => 'Es posible que los cambios que realizaste no se guarden.';

  @override
  String get settings_privacy_confirmation => '¿Cambiar la configuración de privacidad de la comunidad?';

  @override
  String get settings_privacy_description => 'Esta comunidad tiene publicaciones destacadas a nivel mundial. Cambiar la comunidad de pública a privada eliminará estas publicaciones de ser destacadas a nivel mundial.';

  @override
  String get general_add => 'Agregar';

  @override
  String get general_loading => 'Cargando...';

  @override
  String get general_leave => 'Salir';

  @override
  String get general_error => 'Ups, algo salió mal';

  @override
  String get general_edited => 'Editado';

  @override
  String get general_edited_suffix => ' (editado)';

  @override
  String get general_keep_editing => 'Seguir editando';

  @override
  String get general_discard => 'Descartar';

  @override
  String get general_moderator => 'Moderador';

  @override
  String get general_save => 'Guardar';

  @override
  String get general_delete => 'Eliminar';

  @override
  String get general_edit => 'Editar';

  @override
  String get general_close => 'Cerrar';

  @override
  String get general_done => 'Hecho';

  @override
  String get general_post => 'Publicar';

  @override
  String get general_comments => 'Comentarios';

  @override
  String get general_story => 'Historia';

  @override
  String get general_stories => 'Historias';

  @override
  String get general_poll => 'Encuesta';

  @override
  String get general_optional => 'Opcional';

  @override
  String get general_on => 'Encendido';

  @override
  String get general_off => 'Apagado';

  @override
  String get settings_allow_notification => 'Permitir Notificaciones';

  @override
  String get settings_allow_notification_description => 'Activa para recibir notificaciones push de esta comunidad.';

  @override
  String get general_reported => 'reportado';

  @override
  String get general_unreported => 'no reportado';

  @override
  String get general_see_more => '...Ver más';

  @override
  String get general_camera => 'Cámara';

  @override
  String get general_photo => 'Foto';

  @override
  String get general_video => 'Video';

  @override
  String get general_posting => 'Publicando';

  @override
  String get general_my_timeline => 'Mi cronología';

  @override
  String get general_options => 'Opciones';

  @override
  String get post_edit_globally_featured => '¿Editar publicación destacada a nivel mundial?';

  @override
  String get post_edit_globally_featured_description => 'La publicación que estás editando ha sido destacada a nivel mundial. Si editas tu publicación, necesitará ser aprobada nuevamente y ya no será destacada a nivel mundial.';

  @override
  String post_like_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '1 me gusta',
    );
    return '$_temp0';
  }

  @override
  String post_comment_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentarios',
      one: '1 comentario',
    );
    return '$_temp0';
  }

  @override
  String get post_reported => 'Publicación reportada.';

  @override
  String get post_unreported => 'Publicación desreportada.';

  @override
  String profile_followers_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seguidores',
      one: '1 seguidor',
      zero: 'Sin seguidores',
    );
    return '$_temp0';
  }

  @override
  String community_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
      zero: 'Sin miembros',
    );
    return '$_temp0';
  }

  @override
  String profile_posts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicaciones',
      one: 'publicación',
    );
    return '$_temp0';
  }

  @override
  String profile_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'miembros',
      one: 'miembro',
    );
    return '$_temp0';
  }

  @override
  String get user_block => 'Bloquear Usuario';

  @override
  String get user_unblock => 'Desbloquear usuario';

  @override
  String get error_delete_post => 'Error al eliminar la publicación. Por favor, inténtalo de nuevo.';

  @override
  String get error_leave_community => 'No se puede dejar la comunidad';

  @override
  String get error_leave_community_description => 'Eres el único moderador en este grupo. Para dejar la comunidad, nombra a otros miembros como moderadores';

  @override
  String get error_close_community => 'No se puede cerrar la comunidad';

  @override
  String get error_close_community_description => 'Algo salió mal. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get error_max_upload_reached => 'Límite máximo de carga alcanzado';

  @override
  String error_max_upload_image_reached_description(int maxUploads) {
    return 'Has alcanzado el límite de carga de $maxUploads imágenes. Las imágenes adicionales no se guardarán.';
  }

  @override
  String error_max_upload_videos_reached_description(int maxUploads) {
    return 'Has alcanzado el límite de carga de $maxUploads videos. Los videos adicionales no se guardarán.';
  }

  @override
  String get error_edit_post => 'Error al editar la publicación. Por favor, inténtalo de nuevo.';

  @override
  String get error_create_post => 'Error al crear la publicación. Por favor, inténtalo de nuevo.';

  @override
  String error_max_poll_characters(int maxQuestionLength) {
    return 'La pregunta de la encuesta no puede exceder de $maxQuestionLength caracteres.';
  }

  @override
  String error_max_poll_option_characters(int maxQuestionLength) {
    return 'La opción de la encuesta no puede exceder de $maxQuestionLength caracteres.';
  }

  @override
  String get error_create_poll => 'Error al crear la encuesta. Por favor, inténtalo de nuevo.';

  @override
  String get user_profile_unknown_name => 'Desconocido';

  @override
  String get community_all_members => 'Todos los miembros';

  @override
  String get community_moderators => 'Moderadores';

  @override
  String get community_search_member_hint => 'Buscar miembro';

  @override
  String get community_promote_moderator => 'Promover a moderador';

  @override
  String get community_demote_member => 'Degradar a miembro';

  @override
  String get community_remove_member => 'Eliminar de la comunidad';

  @override
  String get user_report => 'Reportar usuario';

  @override
  String get user_unreport => 'Desreportar usuario';

  @override
  String get feed_no_videos => 'Aún no hay videos';

  @override
  String get feed_no_photos => 'Aún no hay fotos';

  @override
  String get feed_no_pinned_posts => 'Aún no hay publicaciones fijadas';

  @override
  String get feed_no_posts => 'Aún no hay publicaciones';

  @override
  String get member_add => 'Añadir miembro';

  @override
  String get search_user_hint => 'Buscar usuario';

  @override
  String get profile_edit => 'Editar perfil';

  @override
  String get profile_update_success => '¡Perfil actualizado correctamente!';

  @override
  String get profile_update_failed => 'Error al guardar tu perfil. Por favor, inténtalo de nuevo.';
}

/// The translations for Spanish Castilian, as used in Peru (`es_PE`).
class AppLocalizationsEsPe extends AppLocalizationsEs {
  AppLocalizationsEsPe(): super('es_PE');

  @override
  String get community_title => 'Comunidad';

  @override
  String get tab_newsfeed => 'Noticias';

  @override
  String get tab_explore => 'Explorar';

  @override
  String get tab_my_communities => 'Mis Comunidades';

  @override
  String get global_search_hint => 'Buscar comunidad y usuario';

  @override
  String get search_my_community_hint => 'Buscar mi comunidad';

  @override
  String get search_no_results => 'No se encontraron resultados';

  @override
  String get title_communities => 'Comunidades';

  @override
  String get title_users => 'Usuarios';

  @override
  String get general_cancel => 'Cancelar';

  @override
  String get general_ok => 'OK';

  @override
  String get general_confirm => 'Confirmar';

  @override
  String get general_featured => 'Destacado';

  @override
  String get profile_followers => 'Seguidores';

  @override
  String get profile_following => 'Siguiendo';

  @override
  String get profile_posts => 'Publicaciones';

  @override
  String get post_create => 'Crear publicación';

  @override
  String get post_edit => 'Editar publicación';

  @override
  String get post_create_hint => '¿Qué está pasando...?';

  @override
  String get post_delete => 'Eliminar publicación';

  @override
  String get post_delete_description => 'Esta publicación se eliminará permanentemente.';

  @override
  String get post_delete_confirmation => '¿Eliminar publicación?';

  @override
  String get post_delete_confirmation_description => '¿Quieres eliminar tu publicación?';

  @override
  String get post_report => 'Reportar publicación';

  @override
  String get post_unreport => 'Desreportar publicación';

  @override
  String get post_like => 'Me gusta';

  @override
  String get post_comment => 'Comentar';

  @override
  String get post_share => 'Compartir';

  @override
  String get post_discard => '¿Descartar esta publicación?';

  @override
  String get post_discard_description => 'La publicación se eliminará permanentemente. No se puede deshacer.';

  @override
  String get post_write_comment => 'Escribe un comentario...';

  @override
  String get poll_duration => 'Duración de la encuesta';

  @override
  String get poll_duration_hint => 'Siempre puedes cerrar la encuesta antes de la duración establecida.';

  @override
  String get poll_custom_edn_date => 'Fecha de finalización personalizada';

  @override
  String get poll_close => 'Cerrar encuesta';

  @override
  String get poll_close_description => 'Esta encuesta está cerrada. Ya no puedes votar.';

  @override
  String get poll_vote => 'Votar';

  @override
  String get poll_results => 'Ver resultados';

  @override
  String get poll_back_to_vote => 'Volver a votar';

  @override
  String poll_vote_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String poll_total_votes(int count, String plusSign) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Votado por $count$plusSign participantes',
      one: 'Votado por 1 participante',
      zero: 'Sin votos',
    );
    return '$_temp0';
  }

  @override
  String poll_see_more_options(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count opciones más',
      one: 'Ver 1 opción más',
    );
    return '$_temp0';
  }

  @override
  String get poll_see_full_results => 'Ver resultados completos';

  @override
  String get poll_voted => 'Votado por ti';

  @override
  String get poll_and_you => ' y tú';

  @override
  String get poll_remaining_time => 'restante';

  @override
  String get poll_vote_error => 'Error al votar en la encuesta. Por favor, inténtalo de nuevo.';

  @override
  String get poll_ended => 'Finalizado';

  @override
  String get poll_single_choice => 'Selecciona una opción';

  @override
  String get poll_multiple_choice => 'Selecciona una o más opciones';

  @override
  String poll_options_description(int minOptions) {
    return 'La encuesta debe contener al menos $minOptions opciones.';
  }

  @override
  String get poll_question => 'Pregunta de la encuesta';

  @override
  String get poll_question_hint => '¿Cuál es tu pregunta de la encuesta?';

  @override
  String get comment_create_hint => 'Di algo agradable...';

  @override
  String get comment_reply => 'Responder';

  @override
  String get comment_reply_to => 'Respondiendo a ';

  @override
  String comment_view_reply_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count respuestas',
      one: 'Ver 1 respuesta',
    );
    return '$_temp0';
  }

  @override
  String get comment_report => 'Reportar comentario';

  @override
  String get comment_unreport => 'Desreportar comentario';

  @override
  String get comment_reply_report => 'Reportar respuesta';

  @override
  String get comment_reply_unreport => 'Desreportar respuesta';

  @override
  String get comment_edit => 'Editar comentario';

  @override
  String get comment_reply_edit => 'Editar respuesta';

  @override
  String get comment_delete => 'Eliminar comentario';

  @override
  String get comment_reply_delete => 'Eliminar respuesta';

  @override
  String comment_delete_description(String content) {
    return 'Este $content se eliminará permanentemente.';
  }

  @override
  String get community_close => '¿Cerrar comunidad?';

  @override
  String get community_close_description => 'Todos los miembros serán eliminados de la comunidad. Todas las publicaciones, mensajes, reacciones y medios compartidos en la comunidad serán eliminados. Esto no se puede deshacer.';

  @override
  String get community_join => 'Unirse';

  @override
  String get community_joined => 'Unido';

  @override
  String get community_recommended_for_you => 'Recomendado para ti';

  @override
  String get community_trending_now => 'En tendencia ahora';

  @override
  String get community_placeholder_members => '1.2K miembros';

  @override
  String get community_leave => 'Dejar comunidad';

  @override
  String get community_leave_description => 'Dejar la comunidad. Ya no podrás publicar e interactuar en esta comunidad.';

  @override
  String get community_create => 'Crear comunidad';

  @override
  String get community_name => 'Nombre de la comunidad';

  @override
  String get community_name_hint => 'Nombra tu comunidad';

  @override
  String get community_description_hint => 'Ingresa una descripción';

  @override
  String get community_edit => 'Editar comunidad';

  @override
  String get community_members => 'Miembros';

  @override
  String get community_private => 'Privado';

  @override
  String get community_public => 'Público';

  @override
  String get community_public_description => 'Cualquiera puede unirse, ver y buscar las publicaciones en esta comunidad.';

  @override
  String get community_private_description => 'Solo los miembros invitados por los moderadores pueden unirse, ver y buscar las publicaciones en esta comunidad.';

  @override
  String get community_about => 'Acerca de';

  @override
  String get categories_title => 'Categorías';

  @override
  String get category_hint => 'Seleccionar categoría';

  @override
  String get category_select_title => 'Seleccionar Categoría';

  @override
  String get category_add => 'Agregar Categoría';

  @override
  String get community_pending_posts => 'Publicaciones pendientes';

  @override
  String get commnuity_pending_post_reviewing => 'Tus publicaciones están pendientes de revisión';

  @override
  String commnuity_pending_post_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones necesitan aprobación',
      one: '$count publicación necesita aprobación',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Solicitudes pendientes',
      one: 'Solicitud pendiente',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_message(String displayCount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicaciones requieren',
      one: 'publicación requiere',
    );
    return '$displayCount $_temp0 aprobación';
  }

  @override
  String get community_basic_info => 'Información básica';

  @override
  String get community_discard_confirmation => '¿Salir sin terminar?';

  @override
  String get community_discard_description => 'Tu progreso no se guardará y tu comunidad no se creará.';

  @override
  String get message_send => 'Enviar';

  @override
  String get message_typing => 'está escribiendo...';

  @override
  String get message_placeholder => 'Escribe un mensaje...';

  @override
  String get settings_title => 'Configuraciones';

  @override
  String get settings_notifications => 'Notificaciones';

  @override
  String get settings_new_posts => 'Nuevas publicaciones';

  @override
  String get settings_new_posts_description => 'Recibe notificaciones cuando alguien cree nuevas publicaciones en esta comunidad.';

  @override
  String get settings_react_posts => 'Reaccionar a publicaciones';

  @override
  String get settings_react_posts_description => 'Recibe notificaciones cuando alguien reaccione a tus publicaciones en esta comunidad.';

  @override
  String get settings_react_comments => 'Reaccionar a comentarios';

  @override
  String get settings_react_comments_description => 'Recibe notificaciones cuando alguien le guste tu comentario en esta comunidad.';

  @override
  String get settings_new_comments => 'Nuevos comentarios';

  @override
  String get settings_new_comments_description => 'Recibe notificaciones cuando alguien comente en tu publicación en esta comunidad.';

  @override
  String get settings_new_replies => 'Respuestas';

  @override
  String get settings_new_replies_description => 'Recibe notificaciones cuando alguien comente en tus comentarios en esta comunidad.';

  @override
  String get settings_allow_stories_comments => 'Permitir comentarios en historias de la comunidad';

  @override
  String get settings_allow_stories_comments_description => 'Activa para recibir comentarios en historias en esta comunidad.';

  @override
  String get settings_new_stories => 'Nuevas historias';

  @override
  String get settings_new_stories_description => 'Recibe notificaciones cuando alguien cree una nueva historia en esta comunidad.';

  @override
  String get settings_story_reactions => 'Reacciones a historias';

  @override
  String get settings_story_reactions_description => 'Recibe notificaciones cuando alguien reaccione a tu historia en esta comunidad.';

  @override
  String get settings_story_comments => 'Comentarios en historias';

  @override
  String get settings_story_comments_description => 'Recibe notificaciones cuando alguien comente en tu historia en esta comunidad.';

  @override
  String get settings_everyone => 'Todos';

  @override
  String get settings_only_moderators => 'Solo moderadores';

  @override
  String get settings_only_admins => 'Solo los administradores pueden publicar';

  @override
  String get settings_privacy => 'Privacidad';

  @override
  String get settings_permissions => 'Permisos de la comunidad';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_leave_confirmation => '¿Salir sin terminar?';

  @override
  String get settings_leave_description => 'Es posible que los cambios que realizaste no se guarden.';

  @override
  String get settings_privacy_confirmation => '¿Cambiar la configuración de privacidad de la comunidad?';

  @override
  String get settings_privacy_description => 'Esta comunidad tiene publicaciones destacadas a nivel mundial. Cambiar la comunidad de pública a privada eliminará estas publicaciones de ser destacadas a nivel mundial.';

  @override
  String get general_add => 'Agregar';

  @override
  String get general_loading => 'Cargando...';

  @override
  String get general_leave => 'Salir';

  @override
  String get general_error => 'Ups, algo salió mal';

  @override
  String get general_edited => 'Editado';

  @override
  String get general_edited_suffix => ' (editado)';

  @override
  String get general_keep_editing => 'Seguir editando';

  @override
  String get general_discard => 'Descartar';

  @override
  String get general_moderator => 'Moderador';

  @override
  String get general_save => 'Guardar';

  @override
  String get general_delete => 'Eliminar';

  @override
  String get general_edit => 'Editar';

  @override
  String get general_close => 'Cerrar';

  @override
  String get general_done => 'Hecho';

  @override
  String get general_post => 'Publicar';

  @override
  String get general_comments => 'Comentarios';

  @override
  String get general_story => 'Historia';

  @override
  String get general_stories => 'Historias';

  @override
  String get general_poll => 'Encuesta';

  @override
  String get general_optional => 'Opcional';

  @override
  String get general_on => 'Encendido';

  @override
  String get general_off => 'Apagado';

  @override
  String get settings_allow_notification => 'Permitir Notificaciones';

  @override
  String get settings_allow_notification_description => 'Activa para recibir notificaciones push de esta comunidad.';

  @override
  String get general_reported => 'reportado';

  @override
  String get general_unreported => 'no reportado';

  @override
  String get general_see_more => '...Ver más';

  @override
  String get general_camera => 'Cámara';

  @override
  String get general_photo => 'Foto';

  @override
  String get general_video => 'Video';

  @override
  String get general_posting => 'Publicando';

  @override
  String get general_my_timeline => 'Mi cronología';

  @override
  String get general_options => 'Opciones';

  @override
  String get post_edit_globally_featured => '¿Editar publicación destacada a nivel mundial?';

  @override
  String get post_edit_globally_featured_description => 'La publicación que estás editando ha sido destacada a nivel mundial. Si editas tu publicación, necesitará ser aprobada nuevamente y ya no será destacada a nivel mundial.';

  @override
  String post_like_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '1 me gusta',
    );
    return '$_temp0';
  }

  @override
  String post_comment_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentarios',
      one: '1 comentario',
    );
    return '$_temp0';
  }

  @override
  String get post_reported => 'Publicación reportada.';

  @override
  String get post_unreported => 'Publicación desreportada.';

  @override
  String profile_followers_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seguidores',
      one: '1 seguidor',
      zero: 'Sin seguidores',
    );
    return '$_temp0';
  }

  @override
  String community_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
      zero: 'Sin miembros',
    );
    return '$_temp0';
  }

  @override
  String profile_posts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicaciones',
      one: 'publicación',
    );
    return '$_temp0';
  }

  @override
  String profile_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'miembros',
      one: 'miembro',
    );
    return '$_temp0';
  }

  @override
  String get user_block => 'Bloquear Usuario';

  @override
  String get user_unblock => 'Desbloquear usuario';

  @override
  String get error_delete_post => 'Error al eliminar la publicación. Por favor, inténtalo de nuevo.';

  @override
  String get error_leave_community => 'No se puede dejar la comunidad';

  @override
  String get error_leave_community_description => 'Eres el único moderador en este grupo. Para dejar la comunidad, nombra a otros miembros como moderadores';

  @override
  String get error_close_community => 'No se puede cerrar la comunidad';

  @override
  String get error_close_community_description => 'Algo salió mal. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get error_max_upload_reached => 'Límite máximo de carga alcanzado';

  @override
  String error_max_upload_image_reached_description(int maxUploads) {
    return 'Has alcanzado el límite de carga de $maxUploads imágenes. Cualquier imagen adicional no se guardará.';
  }

  @override
  String error_max_upload_videos_reached_description(int maxUploads) {
    return 'Has alcanzado el límite de carga de $maxUploads videos. Cualquier video adicional no se guardará.';
  }

  @override
  String get error_edit_post => 'Error al editar la publicación. Por favor, inténtalo de nuevo.';

  @override
  String get error_create_post => 'Error al crear la publicación. Por favor, inténtalo de nuevo.';

  @override
  String error_max_poll_characters(int maxQuestionLength) {
    return 'La pregunta de la encuesta no puede exceder los $maxQuestionLength caracteres.';
  }

  @override
  String error_max_poll_option_characters(int maxQuestionLength) {
    return 'La opción de la encuesta no puede exceder los $maxQuestionLength caracteres.';
  }

  @override
  String get error_create_poll => 'Error al crear la encuesta. Por favor, inténtalo de nuevo.';

  @override
  String get user_profile_unknown_name => 'Desconocido';

  @override
  String get community_all_members => 'Todos los miembros';

  @override
  String get community_moderators => 'Moderadores';

  @override
  String get community_search_member_hint => 'Buscar miembro';

  @override
  String get community_promote_moderator => 'Promover a moderador';

  @override
  String get community_demote_member => 'Degradar a miembro';

  @override
  String get community_remove_member => 'Eliminar de la comunidad';

  @override
  String get user_report => 'Reportar usuario';

  @override
  String get user_unreport => 'Desreportar usuario';

  @override
  String get feed_no_videos => 'Aún no hay videos';

  @override
  String get feed_no_photos => 'Aún no hay fotos';

  @override
  String get feed_no_pinned_posts => 'Aún no hay publicaciones fijadas';

  @override
  String get feed_no_posts => 'Aún no hay publicaciones';

  @override
  String get member_add => 'Agregar miembro';

  @override
  String get search_user_hint => 'Buscar usuario';

  @override
  String get profile_edit => 'Editar perfil';

  @override
  String get profile_update_success => '¡Perfil actualizado con éxito!';

  @override
  String get profile_update_failed => 'Error al guardar tu perfil. Por favor, inténtalo nuevamente.';
}
