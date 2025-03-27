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
  String get search_no_results => 'No se encontraron resultados';

  @override
  String get title_communities => 'Comunidades';

  @override
  String get title_users => 'Usuarios';

  @override
  String get general_cancel => 'Cancelar';

  @override
  String get general_featured => 'Destacado';

  @override
  String get profile_edit => 'Editar perfil';

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
  String get comment_create_hint => 'Say something nice...';

  @override
  String get comment_reply => 'Reply';

  @override
  String get comment_reply_to => 'Replying to ';

  @override
  String comment_view_reply_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'View $count reply',
      one: 'View 1 reply',
    );
    return '$_temp0';
  }

  @override
  String get comment_report => 'Report comment';

  @override
  String get comment_unreport => 'Unreport comment';

  @override
  String get comment_reply_report => 'Report reply';

  @override
  String get comment_reply_unreport => 'Unreport reply';

  @override
  String get comment_edit => 'Edit comment';

  @override
  String get comment_reply_edit => 'Edit reply';

  @override
  String get comment_delete => 'Delete comment';

  @override
  String get comment_reply_delete => 'Delete reply';

  @override
  String comment_delete_description(String content) {
    return 'This $content will be permanently deleted.';
  }

  @override
  String get community_close => 'Close community?';

  @override
  String get community_close_description => 'All members will be removed from  the community. All posts, messages, reactions, and media shared in community will be deleted. This cannot be undone.';

  @override
  String get community_join => 'Join';

  @override
  String get community_leave => 'Leave community';

  @override
  String get community_leave_description => 'Leave the community. You will no longer be able to post and interact in this community.';

  @override
  String get community_create => 'Create Community';

  @override
  String get community_name => 'Community name';

  @override
  String get community_name_hint => 'Name your community';

  @override
  String get community_description_hint => 'Enter description';

  @override
  String get community_edit => 'Edit Community';

  @override
  String get community_members => 'Members';

  @override
  String get community_private => 'Private';

  @override
  String get community_public => 'Public';

  @override
  String get community_public_description => 'Anyone can join, view and search the posts in this community.';

  @override
  String get community_private_description => 'Only members invited by the moderators can join, view, and search the posts in this community.';

  @override
  String get community_about => 'About';

  @override
  String get categories_title => 'Categories';

  @override
  String get category_hint => 'Select category';

  @override
  String get community_pending_posts => 'Pending Posts';

  @override
  String get commnuity_pending_post_reviewing => 'Your posts are pending for review';

  @override
  String commnuity_pending_post_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts need approval',
      one: '$count post need approval',
    );
    return '$_temp0';
  }

  @override
  String get community_basic_info => 'Basic Info';

  @override
  String get community_discard_confirmation => 'Leave without finishing?';

  @override
  String get community_discard_description => 'Your progress won’t be saved and your community won’t be created.';

  @override
  String get message_send => 'Send';

  @override
  String get message_typing => 'is typing...';

  @override
  String get message_placeholder => 'Type a message...';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_new_posts => 'New posts';

  @override
  String get settings_new_posts_description => 'Receive notifications when someone create new posts in this community.';

  @override
  String get settings_react_posts => 'React posts';

  @override
  String get settings_react_posts_description => 'Receive notifications when someone make a reaction to your posts in this community.';

  @override
  String get settings_react_comments => 'React comments';

  @override
  String get settings_react_comments_description => 'Receive notifications when someone like your comment in this community.';

  @override
  String get settings_new_comments => 'New comments';

  @override
  String get settings_new_comments_description => 'Receive notifications when someone comments on your post in this community.';

  @override
  String get settings_new_replies => 'Replies';

  @override
  String get settings_new_replies_description => 'Receive notifications when someone comment to your comments in this community.';

  @override
  String get settings_allow_stories_comments => 'Allow comments on community stories';

  @override
  String get settings_allow_stories_comments_description => 'Turn on to receive comments on stories in this community.';

  @override
  String get settings_new_stories => 'New stories';

  @override
  String get settings_new_stories_description => 'Receive notifications when someone creates a new story in this community.';

  @override
  String get settings_story_reactions => 'Story reactions';

  @override
  String get settings_story_reactions_description => 'Receive notifications when someone reacts to your story in this community.';

  @override
  String get settings_story_comments => 'Story comments';

  @override
  String get settings_story_comments_description => 'Receive notifications when someone comments on your story in this community.';

  @override
  String get settings_everyone => 'Everyone';

  @override
  String get settings_only_moderators => 'Only moderators';

  @override
  String get settings_privacy => 'Privacy';

  @override
  String get settings_permissions => 'Community permissions';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_leave_confirmation => 'Leave without finishing?';

  @override
  String get settings_leave_description => 'Your changes that you made may not be saved.';

  @override
  String get settings_privacy_confirmation => 'Change community privacy settings?';

  @override
  String get settings_privacy_description => 'This community has globally featured posts. Changing the community from public to private will remove these posts from being featured globally.';

  @override
  String get general_add => 'Add';

  @override
  String get general_loading => 'Loading...';

  @override
  String get general_leave => 'Leave';

  @override
  String get general_error => 'Oops, something went wrong';

  @override
  String get general_edited => 'Edited';

  @override
  String get general_edited_suffix => ' (edited)';

  @override
  String get general_keep_editing => 'Keep editing';

  @override
  String get general_discard => 'Discard';

  @override
  String get general_moderator => 'Moderator';

  @override
  String get general_save => 'Save';

  @override
  String get general_delete => 'Delete';

  @override
  String get general_edit => 'Edit';

  @override
  String get general_close => 'Close';

  @override
  String get general_done => 'Done';

  @override
  String get general_post => 'Post';

  @override
  String get general_comments => 'Comments';

  @override
  String get general_story => 'Story';

  @override
  String get general_stories => 'Stories';

  @override
  String get general_poll => 'Poll';

  @override
  String get general_optional => 'Optional';

  @override
  String get general_on => 'On';

  @override
  String get general_off => 'Off';

  @override
  String get general_reported => 'reported';

  @override
  String get general_see_more => '...See more';

  @override
  String get general_camera => 'Camera';

  @override
  String get general_photo => 'Photo';

  @override
  String get general_video => 'Video';

  @override
  String get general_posting => 'Posting';

  @override
  String get general_my_timeline => 'My Timeline';

  @override
  String get general_options => 'Options';

  @override
  String get post_edit_globally_featured => 'Edit globally featured post?';

  @override
  String get post_edit_globally_featured_description => 'The post you\'re editing has been featured globally. If you edit your post, it would need to be re-approved, and will no longer be globally featured.';

  @override
  String post_like_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
    );
    return '$_temp0';
  }

  @override
  String post_comment_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
    );
    return '$_temp0';
  }

  @override
  String get post_reported => 'Post reported.';

  @override
  String get post_unreported => 'Post unreported.';

  @override
  String profile_followers_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count followers',
      one: '1 follower',
      zero: 'No followers',
    );
    return '$_temp0';
  }

  @override
  String community_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
      zero: 'No members',
    );
    return '$_temp0';
  }

  @override
  String profile_posts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'posts',
      one: 'post',
    );
    return '$_temp0';
  }

  @override
  String profile_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'members',
      one: 'member',
    );
    return '$_temp0';
  }

  @override
  String get user_block => 'Block user';

  @override
  String get user_unblock => 'Unblock user';

  @override
  String get error_delete_post => 'Failed to delete post. Please try again.';

  @override
  String get error_leave_community => 'Unable to leave community';

  @override
  String get error_leave_community_description => 'You’re the only moderator in this group. To leave community, nominate other members to moderator role';

  @override
  String get error_close_community => 'Unable to close community';

  @override
  String get error_close_community_description => 'Something went wrong. Please try again later.';

  @override
  String get error_max_upload_reached => 'Maximum upload limit reached';

  @override
  String error_max_upload_image_reached_description(int maxUploads) {
    return 'You’ve reached the upload limit of $maxUploads images. Any additional images will not be saved.';
  }

  @override
  String error_max_upload_videos_reached_description(int maxUploads) {
    return 'You’ve reached the upload limit of $maxUploads videos. Any additional videos will not be saved.';
  }

  @override
  String get error_edit_post => 'Failed to edit post. Please try again.';

  @override
  String get error_create_post => 'Failed to create post. Please try again.';

  @override
  String error_max_poll_characters(int maxQuestionLength) {
    return 'Poll question cannot exceed $maxQuestionLength characters.';
  }

  @override
  String error_max_poll_option_characters(int maxQuestionLength) {
    return 'Poll option cannot exceed $maxQuestionLength characters.';
  }

  @override
  String get error_create_poll => 'Failed to create poll. Please try again.';
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
  String get search_no_results => 'No se encontraron resultados';

  @override
  String get title_communities => 'Comunidades';

  @override
  String get title_users => 'Usuarios';

  @override
  String get general_cancel => 'Cancelar';

  @override
  String get general_featured => 'Destacado';

  @override
  String get profile_edit => 'Editar perfil';

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
  String get general_reported => 'reportado';

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
  String get user_block => 'Bloquear usuario';

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
  String get search_no_results => 'No se encontraron resultados';

  @override
  String get title_communities => 'Comunidades';

  @override
  String get title_users => 'Usuarios';

  @override
  String get general_cancel => 'Cancelar';

  @override
  String get general_featured => 'Destacado';

  @override
  String get profile_edit => 'Editar perfil';

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
  String get general_reported => 'reportado';

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
  String get user_block => 'Bloquear usuario';

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
  String get search_no_results => 'No se encontraron resultados';

  @override
  String get title_communities => 'Comunidades';

  @override
  String get title_users => 'Usuarios';

  @override
  String get general_cancel => 'Cancelar';

  @override
  String get general_featured => 'Destacado';

  @override
  String get profile_edit => 'Editar perfil';

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
  String get general_reported => 'reportado';

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
  String get user_block => 'Bloquear usuario';

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
  String get search_no_results => 'No se encontraron resultados';

  @override
  String get title_communities => 'Comunidades';

  @override
  String get title_users => 'Usuarios';

  @override
  String get general_cancel => 'Cancelar';

  @override
  String get general_featured => 'Destacado';

  @override
  String get profile_edit => 'Editar perfil';

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
  String get general_reported => 'reportado';

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
  String get user_block => 'Bloquear usuario';

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
}
