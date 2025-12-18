// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get community_title => 'Comunidade';

  @override
  String get tab_newsfeed => 'Feed de notícias';

  @override
  String get tab_explore => 'Explorar';

  @override
  String get tab_my_communities => 'Minhas Comunidades';

  @override
  String get global_search_hint => 'Pesquisar comunidade e usuário';

  @override
  String get search_my_community_hint => 'Pesquisar minha comunidade';

  @override
  String get search_no_results => 'Nenhum resultado encontrado';

  @override
  String get title_communities => 'Comunidades';

  @override
  String get title_users => 'Usuários';

  @override
  String get general_cancel => 'Cancelar';

  @override
  String get general_ok => 'OK';

  @override
  String get general_confirm => 'Confirmar';

  @override
  String get general_featured => 'Destaque';

  @override
  String get profile_followers => 'Seguidores';

  @override
  String get profile_following => 'Seguindo';

  @override
  String get profile_posts => 'Publicações';

  @override
  String get post_create => 'Criar Publicação';

  @override
  String get post_edit => 'Editar Publicação';

  @override
  String get post_create_hint => 'O que você quer compartilhar?';

  @override
  String get post_delete => 'Excluir Publicação';

  @override
  String get post_delete_description =>
      'Esta publicação será excluída permanentemente.';

  @override
  String get post_delete_confirmation => 'Excluir Publicação?';

  @override
  String get post_delete_confirmation_description =>
      'Você quer excluir sua publicação?';

  @override
  String get post_report => 'Denunciar publicação';

  @override
  String get post_unreport => 'Remover denúncia';

  @override
  String get post_like => 'Curtir';

  @override
  String get post_comment => 'Comentar';

  @override
  String get post_share => 'Compartilhar';

  @override
  String get post_discard => 'Descartar esta publicação?';

  @override
  String get post_discard_description =>
      'A publicação será excluída permanentemente. Não pode ser desfeito.';

  @override
  String get post_write_comment => 'Escreva um comentário...';

  @override
  String get poll_duration => 'Duração da enquete';

  @override
  String get poll_duration_hint =>
      'Você sempre pode fechar a enquete antes do tempo definido.';

  @override
  String get poll_custom_edn_date => 'Data de término personalizada';

  @override
  String get poll_close => 'Fechar enquete';

  @override
  String get poll_close_description =>
      'Esta enquete está fechada. Você não pode mais votar.';

  @override
  String get poll_vote => 'Votar';

  @override
  String get poll_results => 'Ver resultados';

  @override
  String get poll_back_to_vote => 'Voltar para votar';

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
      zero: 'Nenhum voto',
    );
    return '$_temp0';
  }

  @override
  String poll_see_more_options(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count mais opções',
      one: 'Ver 1 mais opção',
    );
    return '$_temp0';
  }

  @override
  String get poll_see_full_results => 'Ver Resultados Completos';

  @override
  String get poll_voted => 'Votado por você';

  @override
  String get poll_and_you => ' e você';

  @override
  String get poll_remaining_time => 'restante';

  @override
  String get poll_vote_error =>
      'Falha ao votar na enquete. Por favor, tente novamente.';

  @override
  String get poll_ended => 'Encerrada';

  @override
  String get poll_single_choice => 'Selecione uma opção';

  @override
  String get poll_multiple_choice => 'Selecione uma ou mais opções';

  @override
  String poll_options_description(int minOptions) {
    return 'A enquete deve conter pelo menos $minOptions opções.';
  }

  @override
  String get poll_question => 'Pergunta da enquete';

  @override
  String get poll_question_hint => 'Qual é a sua pergunta da enquete?';

  @override
  String get comment_create_hint => 'Diga algo legal...';

  @override
  String get comment_reply => 'Responder';

  @override
  String get comment_reply_to => 'Respondendo a ';

  @override
  String comment_view_reply_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count respostas',
      one: 'Ver 1 resposta',
    );
    return '$_temp0';
  }

  @override
  String get comment_report => 'Denunciar comentário';

  @override
  String get comment_unreport => 'Remover denúncia';

  @override
  String get comment_reply_report => 'Denunciar resposta';

  @override
  String get comment_reply_unreport => 'Remover denúncia';

  @override
  String get comment_edit => 'Editar comentário';

  @override
  String get comment_reply_edit => 'Editar resposta';

  @override
  String get comment_delete => 'Excluir comentário';

  @override
  String get comment_reply_delete => 'Excluir resposta';

  @override
  String comment_delete_description(String content) {
    return 'Este $content será excluído permanentemente.';
  }

  @override
  String get comment_create_error_ban_word =>
      'Seu comentário contém uma palavra inadequada. Por favor, revise e exclua.';

  @override
  String get comment_create_error_story_deleted =>
      'Esta história não está mais disponível';

  @override
  String get community_create_success_message =>
      'Comunidade criada com sucesso.';

  @override
  String get community_create_error_message =>
      'Falha ao criar comunidade. Por favor, tente novamente.';

  @override
  String get community_update_success_message =>
      'Comunidade atualizada com sucesso.';

  @override
  String get community_update_error_message =>
      'Falha ao salvar o perfil da comunidade. Por favor, tente novamente.';

  @override
  String get community_leave_success_message =>
      'Você saiu da comunidade com sucesso.';

  @override
  String get community_leave_error_message => 'Falha ao sair da comunidade.';

  @override
  String get community_close_success_message =>
      'Comunidade fechada com sucesso.';

  @override
  String get community_close_error_message => 'Falha ao fechar a comunidade.';

  @override
  String get community_close => 'Fechar comunidade?';

  @override
  String get community_close_description =>
      'Todos os membros serão removidos da comunidade. Todas as publicações, mensagens, reações e mídias compartilhadas na comunidade serão excluídas. Isso não pode ser desfeito.';

  @override
  String get community_join => 'Entrar';

  @override
  String get community_joined => 'Entrou';

  @override
  String get community_recommended_for_you => 'Recomendado para você';

  @override
  String get community_trending_now => 'Em alta agora';

  @override
  String get community_placeholder_members => '1.2K membros';

  @override
  String get community_leave => 'Sair da comunidade';

  @override
  String get community_leave_description =>
      'Sair da comunidade. Você não poderá mais publicar e interagir nesta comunidade.';

  @override
  String get community_create => 'Criar Comunidade';

  @override
  String get community_name => 'Nome da comunidade';

  @override
  String get community_name_hint => 'Nomeie sua comunidade';

  @override
  String get community_description_hint => 'Digite a descrição';

  @override
  String get community_edit => 'Editar Comunidade';

  @override
  String get community_members => 'Membros';

  @override
  String get community_private => 'Privada';

  @override
  String get community_public => 'Pública';

  @override
  String get community_public_description =>
      'Qualquer pessoa pode entrar, visualizar e pesquisar as publicações nesta comunidade.';

  @override
  String get community_private_description =>
      'Apenas membros convidados pelos moderadores podem entrar, visualizar e pesquisar as publicações nesta comunidade.';

  @override
  String get community_about => 'Sobre';

  @override
  String get categories_title => 'Categorias';

  @override
  String get category_hint => 'Selecione a categoria';

  @override
  String get category_select_title => 'Selecionar Categoria';

  @override
  String get category_add => 'Adicionar Categoria';

  @override
  String get community_pending_posts => 'Publicações Pendentes';

  @override
  String get commnuity_pending_post_reviewing =>
      'Suas publicações estão pendentes de revisão';

  @override
  String commnuity_pending_post_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicações precisam de aprovação',
      one: '$count publicação precisa de aprovação',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Solicitações pendentes',
      one: 'Solicitação pendente',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_message(String displayCount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicações requerem',
      one: 'publicação requer',
    );
    return '$displayCount $_temp0 aprovação';
  }

  @override
  String get community_basic_info => 'Informações Básicas';

  @override
  String get community_discard_confirmation => 'Sair sem terminar?';

  @override
  String get community_discard_description =>
      'Seu progresso não será salvo e sua comunidade não será criada.';

  @override
  String get message_send => 'Enviar';

  @override
  String get message_typing => 'está digitando...';

  @override
  String get message_placeholder => 'Digite uma mensagem...';

  @override
  String get message_deleted => 'Esta mensagem foi excluída';

  @override
  String get message_failed_to_send => 'Falha ao enviar a mensagem.';

  @override
  String get message_reply_you_to_yourself => 'Você respondeu a si mesmo';

  @override
  String get message_reply_to_you => 'Respondeu a você';

  @override
  String get message_reply_you => 'Você respondeu';

  @override
  String get message_reply_to_themself => 'Respondeu a si mesmo';

  @override
  String get message_reply_you_to_deleted =>
      'Você respondeu a uma mensagem excluída';

  @override
  String get message_reply_to_deleted => 'Respondeu a uma mensagem excluída';

  @override
  String get message_unknown_user => 'Desconhecido';

  @override
  String get settings_title => 'Configurações';

  @override
  String get settings_notifications => 'Notificações';

  @override
  String get settings_new_posts => 'Novas publicações';

  @override
  String get settings_new_posts_description =>
      'Receba notificações quando alguém criar novas publicações nesta comunidade.';

  @override
  String get settings_react_posts => 'Reações às publicações';

  @override
  String get settings_react_posts_description =>
      'Receba notificações quando alguém reagir às suas publicações nesta comunidade.';

  @override
  String get settings_react_comments => 'Reações aos comentários';

  @override
  String get settings_react_comments_description =>
      'Receba notificações quando alguém curtir seu comentário nesta comunidade.';

  @override
  String get settings_new_comments => 'Novos comentários';

  @override
  String get settings_new_comments_description =>
      'Receba notificações quando alguém comentar em sua publicação nesta comunidade.';

  @override
  String get settings_new_replies => 'Respostas';

  @override
  String get settings_new_replies_description =>
      'Receba notificações quando alguém comentar em seus comentários nesta comunidade.';

  @override
  String get settings_allow_stories_comments =>
      'Permitir comentários nas histórias da comunidade';

  @override
  String get settings_allow_stories_comments_description =>
      'Ative para receber comentários nas histórias desta comunidade.';

  @override
  String get settings_new_stories => 'Novas histórias';

  @override
  String get settings_new_stories_description =>
      'Receba notificações quando alguém criar uma nova história nesta comunidade.';

  @override
  String get settings_story_reactions => 'Reações às histórias';

  @override
  String get settings_story_reactions_description =>
      'Receba notificações quando alguém reagir à sua história nesta comunidade.';

  @override
  String get settings_story_comments => 'Comentários nas histórias';

  @override
  String get settings_story_comments_description =>
      'Receba notificações quando alguém comentar em sua história nesta comunidade.';

  @override
  String get settings_everyone => 'Todos';

  @override
  String get settings_only_moderators => 'Apenas moderadores';

  @override
  String get settings_only_admins => 'Apenas administradores podem publicar';

  @override
  String get settings_privacy => 'Privacidade';

  @override
  String get settings_permissions => 'Permissões da comunidade';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_leave_confirmation => 'Sair sem terminar?';

  @override
  String get settings_leave_description =>
      'As alterações que você fez podem não ser salvas.';

  @override
  String get settings_privacy_confirmation =>
      'Alterar as configurações de privacidade da comunidade?';

  @override
  String get settings_privacy_description =>
      'Esta comunidade tem publicações destacadas globalmente. Alterar a comunidade de pública para privada removerá essas publicações de serem destacadas globalmente.';

  @override
  String get general_add => 'Adicionar';

  @override
  String get general_loading => 'Carregando...';

  @override
  String get general_leave => 'Sair';

  @override
  String get general_error => 'Ops, algo deu errado';

  @override
  String get general_edited => 'Editado';

  @override
  String get general_edited_suffix => ' (editado)';

  @override
  String get general_keep_editing => 'Continuar editando';

  @override
  String get general_discard => 'Descartar';

  @override
  String get general_moderator => 'Moderador';

  @override
  String get general_save => 'Salvar';

  @override
  String get general_delete => 'Excluir';

  @override
  String get general_edit => 'Editar';

  @override
  String get general_close => 'Fechar';

  @override
  String get general_done => 'Concluído';

  @override
  String get general_post => 'Publicar';

  @override
  String get general_comments => 'Comentários';

  @override
  String get general_story => 'História';

  @override
  String get general_stories => 'Histórias';

  @override
  String get general_poll => 'Enquete';

  @override
  String get general_optional => 'Opcional';

  @override
  String get general_on => 'Ativado';

  @override
  String get general_off => 'Desativado';

  @override
  String get settings_allow_notification => 'Permitir Notificação';

  @override
  String get settings_allow_notification_description =>
      'Ative para receber notificações push desta comunidade.';

  @override
  String get general_reported => 'denunciado';

  @override
  String get general_unreported => 'não denunciado';

  @override
  String get general_see_more => '...Ver mais';

  @override
  String get general_camera => 'Câmera';

  @override
  String get general_photo => 'Foto';

  @override
  String get general_video => 'Vídeo';

  @override
  String get general_posting => 'Publicando';

  @override
  String get general_my_timeline => 'Minha Linha do Tempo';

  @override
  String get general_options => 'Opções';

  @override
  String get general_go_back => 'Voltar';

  @override
  String get post_unavailable_title => 'Algo deu errado';

  @override
  String get post_unavailable_description =>
      'O conteúdo que você está procurando não está disponível.';

  @override
  String get comment_deleted_message => 'Este comentário foi excluído';

  @override
  String get comment_reply_deleted_message => 'Esta resposta foi excluída';

  @override
  String get post_edit_globally_featured =>
      'Editar publicação destacada globalmente?';

  @override
  String get post_edit_globally_featured_description =>
      'A publicação que você está editando foi destacada globalmente. Se você editar sua publicação, ela precisará ser reaprovação e não será mais destacada globalmente.';

  @override
  String post_like_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count curtidas',
      one: '1 curtida',
      zero: '0 curtidas',
    );
    return '$_temp0';
  }

  @override
  String post_comment_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentários',
      one: '1 comentário',
      zero: '0 comentários',
    );
    return '$_temp0';
  }

  @override
  String get post_reported => 'Publicação denunciada.';

  @override
  String get post_unreported => 'Denúncia removida.';

  @override
  String profile_followers_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seguidores',
      one: '1 seguidor',
      zero: 'Nenhum seguidor',
    );
    return '$_temp0';
  }

  @override
  String community_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '1 membro',
      zero: 'Nenhum membro',
    );
    return '$_temp0';
  }

  @override
  String profile_posts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicações',
      one: 'publicação',
    );
    return '$_temp0';
  }

  @override
  String profile_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'membros',
      one: 'membro',
    );
    return '$_temp0';
  }

  @override
  String get user_block => 'Bloquear usuário';

  @override
  String get user_unblock => 'Desbloquear usuário';

  @override
  String get error_delete_post =>
      'Falha ao excluir a publicação. Por favor, tente novamente.';

  @override
  String get error_leave_community => 'Não foi possível sair da comunidade';

  @override
  String get error_leave_community_description =>
      'Você é o único moderador deste grupo. Para sair da comunidade, nomeie outros membros para o cargo de moderador';

  @override
  String get error_close_community => 'Não foi possível fechar a comunidade';

  @override
  String get error_close_community_description =>
      'Algo deu errado. Por favor, tente novamente mais tarde.';

  @override
  String get error_max_upload_reached => 'Limite máximo de upload atingido';

  @override
  String error_max_upload_image_reached_description(int maxUploads) {
    return 'Você atingiu o limite de upload de $maxUploads imagens. Quaisquer imagens adicionais não serão salvas.';
  }

  @override
  String error_max_upload_videos_reached_description(int maxUploads) {
    return 'Você atingiu o limite de upload de $maxUploads vídeos. Quaisquer vídeos adicionais não serão salvos.';
  }

  @override
  String get error_edit_post =>
      'Falha ao editar a publicação. Por favor, tente novamente.';

  @override
  String get error_create_post =>
      'Falha ao criar a publicação. Por favor, tente novamente.';

  @override
  String error_max_poll_characters(int maxQuestionLength) {
    return 'A pergunta da enquete não pode exceder $maxQuestionLength caracteres.';
  }

  @override
  String error_max_poll_option_characters(int maxQuestionLength) {
    return 'A opção da enquete não pode exceder $maxQuestionLength caracteres.';
  }

  @override
  String get error_create_poll =>
      'Falha ao criar a enquete. Por favor, tente novamente.';

  @override
  String get error_poll_end_time_must_be_future =>
      'O horário de término da enquete deve estar no futuro. Selecione uma data e hora válidas.';

  @override
  String get error_message_too_long_title => 'Não é possível enviar a mensagem';

  @override
  String get error_message_too_long_description =>
      'Sua mensagem é muito longa. Por favor, encurte sua mensagem e tente novamente.';

  @override
  String get user_profile_unknown_name => 'Desconhecido';

  @override
  String get user_profile_deleted_name => 'Usuário excluído';

  @override
  String get community_all_members => 'Todos os membros';

  @override
  String get community_moderators => 'Moderadores';

  @override
  String get community_search_member_hint => 'Buscar membro';

  @override
  String get community_promote_moderator => 'Promover a moderador';

  @override
  String get community_demote_member => 'Rebaixar para membro';

  @override
  String get community_remove_member => 'Remover da comunidade';

  @override
  String get user_report => 'Denunciar usuário';

  @override
  String get user_unreport => 'Remover denúncia de usuário';

  @override
  String get feed_no_videos => 'Ainda sem vídeos';

  @override
  String get feed_no_photos => 'Ainda sem fotos';

  @override
  String get feed_no_pinned_posts => 'Ainda sem publicação fixada';

  @override
  String get feed_no_posts => 'Ainda sem publicações';

  @override
  String get member_add => 'Adicionar membro';

  @override
  String get search_user_hint => 'Buscar usuário';

  @override
  String get profile_edit => 'Editar Perfil';

  @override
  String get profile_update_success => 'Perfil atualizado com sucesso!';

  @override
  String get profile_update_failed =>
      'Falha ao salvar seu perfil. Por favor, tente novamente.';

  @override
  String get community_post_permission => 'Permissão de publicação';

  @override
  String get community_story_comments => 'Comentários em histórias';

  @override
  String get community_setting_close_label => 'Fechar comunidade';

  @override
  String get community_setting_close_description =>
      'Fechar esta comunidade removerá a página da comunidade e todo o seu conteúdo e comentários.';

  @override
  String get community_post_permission_title_label =>
      'Quem pode publicar nesta comunidade';

  @override
  String get community_post_permission_description_label =>
      'Você pode controlar quem pode criar publicações em sua comunidade.';

  @override
  String get post_item_bottom_nonmember_label =>
      'Entre na comunidade para interagir com todas as publicações';

  @override
  String get notification_turn_on_success => 'Notificação ativada';

  @override
  String get notification_turn_on_error =>
      'Falha ao ativar notificação. Por favor, tente novamente.';

  @override
  String get notification_turn_off_success => 'Notificação desativada';

  @override
  String get notification_turn_off_error =>
      'Falha ao desativar notificação. Por favor, tente novamente.';

  @override
  String get user_report_success => 'Usuário denunciado.';

  @override
  String get user_report_error =>
      'Falha ao denunciar usuário. Por favor, tente novamente.';

  @override
  String get user_unreport_success => 'Denúncia de usuário removida.';

  @override
  String get user_unreport_error =>
      'Falha ao remover denúncia de usuário. Por favor, tente novamente.';

  @override
  String get user_block_success => 'Usuário bloqueado.';

  @override
  String get user_block_error =>
      'Falha ao bloquear usuário. Por favor, tente novamente.';

  @override
  String get user_unblock_success => 'Usuário desbloqueado.';

  @override
  String get user_unblock_error =>
      'Falha ao desbloquear usuário. Por favor, tente novamente.';

  @override
  String get search_no_members_found => 'Nenhum membro encontrado';

  @override
  String get moderator_promotion_title => 'Promoção de moderador';

  @override
  String get moderator_promotion_description =>
      'Tem certeza de que deseja promover este membro a Moderador? Eles terão acesso a todos os recursos de moderador.';

  @override
  String get moderator_promote_button => 'Promover';

  @override
  String get moderator_demotion_title => 'Rebaixamento de moderador';

  @override
  String get moderator_demotion_description =>
      'Tem certeza de que deseja rebaixar este Moderador? Eles perderão acesso a todos os recursos de moderador.';

  @override
  String get moderator_demote_button => 'Rebaixar';

  @override
  String get member_removal_confirm_title => 'Confirmar remoção';

  @override
  String get member_removal_confirm_description =>
      'Tem certeza de que deseja remover este membro do grupo? Eles serão informados de sua remoção.';

  @override
  String get member_remove_button => 'Remover';

  @override
  String get user_ban_confirm_title => 'Confirmar banimento';

  @override
  String get user_ban_confirm_description =>
      'Tem certeza de que deseja banir este usuário? Eles serão removidos do grupo e não poderão encontrá-lo ou entrar novamente a menos que sejam desbanidos.';

  @override
  String get user_ban_button => 'Banir';

  @override
  String get member_add_success =>
      'Membro adicionado com sucesso a esta comunidade.';

  @override
  String get member_add_error =>
      'Falha ao adicionar membro. Por favor, tente novamente.';

  @override
  String get moderator_promote_success => 'Promovido a moderador com sucesso.';

  @override
  String get moderator_promote_error =>
      'Falha ao promover membro. Por favor, tente novamente.';

  @override
  String get moderator_demote_success => 'Rebaixado para membro com sucesso.';

  @override
  String get moderator_demote_error =>
      'Falha ao rebaixar membro. Por favor, tente novamente.';

  @override
  String get member_remove_success => 'Membro removido desta comunidade.';

  @override
  String get member_remove_error =>
      'Falha ao remover membro. Por favor, tente novamente.';

  @override
  String get user_follow_success => 'Usuário seguido.';

  @override
  String get user_follow_error => 'Ops, algo deu errado.';

  @override
  String get user_unfollow_success => 'Deixou de seguir usuário.';

  @override
  String get user_unfollow_error => 'Ops, algo deu errado.';

  @override
  String get post_target_selection_title => 'Publicar em';

  @override
  String get user_feed_blocked_title => 'Você bloqueou este usuário';

  @override
  String get user_feed_blocked_description =>
      'Desbloquear para ver suas publicações.';

  @override
  String get user_feed_private_title => 'Esta conta é privada';

  @override
  String get user_feed_private_description =>
      'Siga este usuário para ver suas publicações.';

  @override
  String get timestamp_just_now => 'Agora mesmo';

  @override
  String get timestamp_now => 'agora';

  @override
  String get chat_notification_turn_on => 'Ativar notificações';

  @override
  String get chat_notification_turn_off => 'Desativar notificações';

  @override
  String get chat_block_user_title => 'Bloquear usuário?';

  @override
  String chat_block_user_description(String displayName) {
    return '$displayName não poderá enviar mensagens para você. Eles não serão notificados de que você os bloqueou.';
  }

  @override
  String get chat_unblock_user_title => 'Desbloquear usuário?';

  @override
  String chat_unblock_user_description(String displayName) {
    return '$displayName agora poderá enviar mensagens para você. Eles não serão notificados de que você os desbloqueou.';
  }

  @override
  String get chat_message_photo => 'Enviar uma foto';

  @override
  String get chat_message_video => 'Enviar um vídeo';

  @override
  String get user_follow_request_new => 'Novas solicitações de seguir';

  @override
  String user_follow_request_approval(String count) {
    return '$count solicitações precisam de sua aprovação';
  }

  @override
  String get user_unfollow => 'Deixar de seguir';

  @override
  String get user_follow_unable_title => 'Não foi possível seguir este usuário';

  @override
  String get user_follow_unable_description =>
      'Ops! algo deu errado. Por favor, tente novamente mais tarde.';

  @override
  String get user_follow => 'Seguir';

  @override
  String get user_follow_cancel => 'Cancelar Solicitação';

  @override
  String get user_following => 'Seguindo';

  @override
  String get user_block_confirm_title => 'Bloquear usuário?';

  @override
  String user_block_confirm_description(String displayName) {
    return '$displayName não poderá ver publicações e comentários que você criou. Eles não serão notificados de que você os bloqueou.';
  }

  @override
  String get user_block_confirm_button => 'Bloquear';

  @override
  String get user_unblock_confirm_title => 'Desbloquear usuário?';

  @override
  String user_unblock_confirm_description(String displayName) {
    return '$displayName agora poderá ver publicações e comentários que você criou. Eles não serão notificados de que você os desbloqueou.';
  }

  @override
  String get user_unblock_confirm_button => 'Desbloquear';

  @override
  String get user_unfollow_confirm_title => 'Deixar de seguir este usuário?';

  @override
  String get user_unfollow_confirm_description =>
      'Se você mudar de ideia, terá que solicitar para segui-los novamente.';

  @override
  String get user_unfollow_confirm_button => 'Deixar de seguir';

  @override
  String get category_default_title => 'Categoria';

  @override
  String get community_empty_state => 'Ainda sem comunidade';

  @override
  String get community_pending_requests_title => 'Solicitações Pendentes';

  @override
  String get community_pending_requests_empty_title =>
      'Sem solicitações pendentes disponíveis';

  @override
  String get community_pending_requests_empty_description =>
      'Ative a revisão de publicações ou aprovação de entrada nas configurações da comunidade para gerenciar solicitações.';

  @override
  String get community_join_requests_coming_soon =>
      'Funcionalidade de solicitações de entrada em breve';

  @override
  String get community_pending_posts_warning =>
      'Recusar publicação pendente excluirá permanentemente a publicação selecionada da comunidade.';

  @override
  String get community_pending_posts_empty => 'Sem publicações pendentes';

  @override
  String get community_pending_post_accept => 'Aceitar';

  @override
  String get community_pending_post_decline => 'Recusar';

  @override
  String get community_pending_post_delete_success => 'Publicação excluída.';

  @override
  String get community_pending_post_delete_error =>
      'Falha ao excluir publicação. Por favor, tente novamente.';

  @override
  String get community_pending_post_approve_success => 'Publicação aceita.';

  @override
  String get community_pending_post_approve_error =>
      'Falha ao aceitar publicação. Esta publicação foi revisada por outro moderador.';

  @override
  String get community_pending_post_decline_success => 'Publicação recusada.';

  @override
  String get community_pending_post_decline_error =>
      'Falha ao recusar publicação. Esta publicação foi revisada por outro moderador.';

  @override
  String poll_option_hint(int optionNumber) {
    return 'Opção $optionNumber';
  }

  @override
  String get poll_add_option => 'Adicionar opção';

  @override
  String get poll_multiple_selection_title => 'Seleção múltipla';

  @override
  String get poll_multiple_selection_description =>
      'Permitir que os participantes votem em mais de uma opção.';

  @override
  String poll_ends_on(String endDate) {
    return 'Termina em $endDate';
  }

  @override
  String get poll_ends_on_label => 'Termina em';

  @override
  String get poll_select_date => 'Selecionar Data';

  @override
  String get poll_select_time => 'Selecionar Hora';

  @override
  String poll_duration_days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get poll_time_hour => 'Hora';

  @override
  String get poll_time_minute => 'Minuto';

  @override
  String get profile_edit_display_name => 'Nome de exibição';

  @override
  String get profile_edit_about => 'Sobre';

  @override
  String get profile_edit_unsupported_image_title =>
      'Tipo de imagem não suportado';

  @override
  String get profile_edit_unsupported_image_description =>
      'Por favor, envie uma imagem PNG ou JPG.';

  @override
  String get profile_edit_inappropriate_image_title => 'Imagem inapropriada';

  @override
  String get profile_edit_inappropriate_image_description =>
      'Por favor, escolha uma imagem diferente para enviar.';

  @override
  String get profile_edit_unsaved_changes_title => 'Alterações não salvas';

  @override
  String get profile_edit_unsaved_changes_description =>
      'Tem certeza de que deseja descartar as alterações? Elas serão perdidas quando você sair desta página.';

  @override
  String get chat_title => 'Chat';

  @override
  String get chat_tab_all => 'Todos';

  @override
  String get chat_tab_direct => 'Direto';

  @override
  String get chat_tab_groups => 'Grupos';

  @override
  String get chat_waiting_for_network => 'Aguardando conexão de rede...';

  @override
  String get chat_direct_chat => 'Chat direto';

  @override
  String get chat_group_chat => 'Chat em grupo';

  @override
  String get chat_archived => 'Arquivado';

  @override
  String get message_editing_message => 'Editando mensagem';

  @override
  String get message_replying_yourself => 'você mesmo';

  @override
  String get message_replied_message => 'Mensagem respondida';

  @override
  String message_replying_to(String displayName) {
    return 'Respondendo a $displayName';
  }

  @override
  String get message_media => 'Mídia';

  @override
  String get chat_loading => 'Carregando chat...';

  @override
  String get chat_blocked_message =>
      'Você não pode enviar mensagens para esta pessoa.';

  @override
  String get chat_notifications_disabled =>
      'Você desativou as notificações para chat';

  @override
  String get chat_archive => 'Arquivar';

  @override
  String get chat_unarchive => 'Desarquivar';

  @override
  String get chat_message_deleted => 'Esta mensagem foi excluída';

  @override
  String get chat_message_no_preview =>
      'Sem visualização disponível para este tipo de mensagem';

  @override
  String get chat_no_message_yet => 'Ainda sem mensagens';

  @override
  String get general_search_hint => 'Pesquisar';

  @override
  String get chat_archived_empty_title => 'Sem chats arquivados';

  @override
  String get chat_archived_title => 'Chats arquivados';

  @override
  String get toast_chat_archived => 'Chat arquivado.';

  @override
  String get toast_chat_unarchived => 'Chat desarquivado.';

  @override
  String get toast_chat_archive_error =>
      'Falha ao arquivar o chat. Por favor, tente novamente';

  @override
  String get toast_chat_unarchive_error =>
      'Falha ao desarquivar o chat. Por favor, tente novamente';

  @override
  String get chat_archive_limit_title => 'Muitos chats arquivados';

  @override
  String get chat_archive_limit_message =>
      'Você pode arquivar no máximo 100 listas de chat.';

  @override
  String get chat_empty_title => 'Ainda sem conversas';

  @override
  String get chat_empty_description => 'Vamos criar um chat para começar.';

  @override
  String get chat_create_new => 'Criar novo chat';

  @override
  String get chat_group_profile_title => 'Perfil do grupo';

  @override
  String get chat_group_profile_error => 'Erro ao carregar perfil';

  @override
  String get chat_group_name_hint => 'Digite o nome do grupo';

  @override
  String get chat_group_name_placeholder => 'Nomeie seu grupo';

  @override
  String get chat_member_permissions_title => 'Permissões de membros';

  @override
  String get chat_member_label => 'Membro';

  @override
  String get chat_select_member_error =>
      'Por favor, selecione pelo menos um usuário';

  @override
  String get message_report_details_hint =>
      'Compartilhe mais detalhes sobre este problema';

  @override
  String get chat_search_tab_chats => 'Chats';

  @override
  String get chat_search_tab_messages => 'Mensagens';

  @override
  String get search_minimum_chars =>
      'Comece sua pesquisa digitando\npelo menos 3 letras';

  @override
  String get permission_camera_title => 'Permitir acesso à sua câmera';

  @override
  String get permission_camera_detail =>
      'Isso permite que o aplicativo tire fotos e grave vídeos da câmera do seu dispositivo.';

  @override
  String get permission_microphone_title => 'Permitir acesso ao seu microfone';

  @override
  String get permission_microphone_detail =>
      'Isso permite que o aplicativo grave áudio para vídeos do microfone do seu dispositivo.';

  @override
  String get permission_open_settings => 'Abrir configurações';

  @override
  String get general_copy => 'Copiar';

  @override
  String get message_report => 'Denunciar';

  @override
  String get message_unreport => 'Remover Denúncia';

  @override
  String get toast_message_copied => 'Copiado.';

  @override
  String get toast_message_reported => 'Mensagem denunciada.';

  @override
  String get toast_message_unreported => 'Denúncia de mensagem retirada.';

  @override
  String get toast_message_report_error =>
      'Falha ao denunciar a mensagem. Por favor, tente novamente.';

  @override
  String get toast_message_unreport_error =>
      'Falha ao retirar a denúncia da mensagem. Por favor, tente novamente.';

  @override
  String get toast_message_delete_error => 'Falha ao excluir a mensagem.';

  @override
  String get toast_permission_denied => 'Permissão negada.';

  @override
  String get toast_photo_saved => 'Foto salva.';

  @override
  String get toast_photo_save_error => 'Falha ao salvar a imagem.';

  @override
  String get toast_video_saved => 'Vídeo salvo.';

  @override
  String get toast_video_save_error => 'Falha ao salvar o vídeo.';

  @override
  String get message_delete_title => 'Excluir esta mensagem?';

  @override
  String get message_delete_description =>
      'Esta mensagem também será removida dos dispositivos dos seus amigos.';

  @override
  String get chat_create_success => 'Grupo de chat criado.';

  @override
  String get chat_create_error => 'Falha ao criar grupo';

  @override
  String get chat_create_error_retry =>
      'Falha ao criar grupo de chat. Por favor, tente novamente.';

  @override
  String get chat_create_title => 'Novo Grupo';

  @override
  String get chat_create_button => 'Criar';

  @override
  String get chat_group_name_label => 'Nome do grupo';

  @override
  String get chat_group_name_optional => '(Opcional)';

  @override
  String get chat_group_name_required => '(Obrigatório)';

  @override
  String get chat_privacy_public => 'Público';

  @override
  String get chat_privacy_public_desc =>
      'Qualquer pessoa pode encontrar o grupo através da pesquisa e participar da conversa.';

  @override
  String get chat_privacy_private => 'Privado';

  @override
  String get chat_privacy_private_desc =>
      'O grupo está oculto nas pesquisas e só é acessível por convite dos moderadores.';

  @override
  String get chat_privacy_warning =>
      'Certifique-se de escolher a configuração de privacidade correta para o seu grupo, pois ela não pode ser alterada posteriormente.';

  @override
  String get chat_select_member_title => 'Novo grupo';

  @override
  String get general_next => 'Próximo';

  @override
  String get settings_group_settings => 'Configurações do grupo';

  @override
  String get settings_group_settings_section => 'Configurações do grupo';

  @override
  String get settings_group_profile => 'Perfil do grupo';

  @override
  String get settings_group_notifications => 'Notificações do grupo';

  @override
  String get settings_member_permissions => 'Permissões de membros';

  @override
  String get settings_all_members => 'Todos os membros';

  @override
  String get settings_banned_users => 'Usuários banidos';

  @override
  String get banned_users_empty_state => 'Nada para ver aqui ainda';

  @override
  String get user_unban_confirm_title => 'Confirmar desbloqueio';

  @override
  String get user_unban_confirm_description =>
      'Tem certeza de que deseja desbloquear este usuário? Eles poderão voltar a participar do grupo.';

  @override
  String get user_unban_button => 'Desbloquear';

  @override
  String get toast_user_unbanned => 'Usuário desbanido.';

  @override
  String get toast_user_unban_error =>
      'Falha ao desbanir o usuário. Por favor, tente novamente.';

  @override
  String get settings_your_preferences => 'Suas preferências';

  @override
  String get general_notifications_lowercase => 'notificações';

  @override
  String get chat_leave_group => 'Sair do grupo';

  @override
  String get chat_leave_group_title => 'Sair do grupo';

  @override
  String get chat_leave_group_confirm =>
      'Se você sair deste grupo, não verá mais novas atividades nem poderá participar neste grupo.';

  @override
  String get chat_leave_group_last_mod_title => 'Você é o último moderador';

  @override
  String get chat_leave_group_last_mod_message =>
      'Você deve promover outro membro a moderador antes de sair.';

  @override
  String get chat_promote_member => 'Promover membro';

  @override
  String get notification_default_mode => 'Modo padrão';

  @override
  String get notification_default_mode_desc =>
      'Por padrão, os membros desta comunidade receberão notificações, mas podem escolher desativá-las.';

  @override
  String get notification_silent_mode => 'Modo silencioso';

  @override
  String get notification_silent_mode_desc =>
      'Sem notificações para todos neste canal. Os membros não podem ativar notificações no canal.';

  @override
  String get notification_subscribe_mode => 'Modo assinatura';

  @override
  String get notification_subscribe_mode_desc =>
      'Todos os membros têm a opção de receber notificações, mas precisam ativá-las. Por padrão, as notificações estão desativadas para cada membro.';

  @override
  String get notification_preference_title => 'Preferência de notificações';

  @override
  String get notification_allow_notifications => 'Permitir notificações';

  @override
  String get notification_allow_notifications_desc =>
      'Ative para receber notificações push deste grupo.';

  @override
  String get notification_disabled_by_moderator =>
      'As notificações do grupo foram desativadas pelo moderador.';

  @override
  String get notification_enabled_toast => 'Notificações ativadas';

  @override
  String get notification_disabled_toast => 'Notificações desativadas';

  @override
  String get settings_messaging => 'Mensagens';

  @override
  String get settings_everyone_desc =>
      'Todos podem enviar uma mensagem no grupo.';

  @override
  String get settings_only_moderators_desc =>
      'Membros que não são moderadores podem ler mensagens, mas não podem enviar nenhuma mensagem.';

  @override
  String get toast_group_chat_left => 'Você saiu do grupo.';

  @override
  String get toast_group_chat_left_error =>
      'Falha ao sair do grupo. Por favor, tente novamente.';

  @override
  String get toast_group_profile_updated => 'Perfil do grupo atualizado.';

  @override
  String get toast_group_profile_error =>
      'Falha ao atualizar o perfil do grupo. Por favor, tente novamente.';

  @override
  String get toast_group_notification_updated =>
      'Notificações do grupo atualizadas.';

  @override
  String get toast_group_notification_error =>
      'Falha ao atualizar as notificações do grupo. Por favor, tente novamente.';

  @override
  String get toast_member_permissions_updated =>
      'Permissões de membros atualizadas.';

  @override
  String get toast_member_permissions_error =>
      'Falha ao atualizar as permissões de membros. Por favor, tente novamente.';

  @override
  String get toast_member_list_updated => 'Lista de membros atualizada.';

  @override
  String get toast_member_list_error =>
      'Falha ao atualizar a lista de membros. Por favor, tente novamente.';

  @override
  String get toast_banned_users_updated => 'Usuários banidos atualizados.';

  @override
  String get toast_banned_users_error =>
      'Falha ao atualizar usuários banidos. Por favor, tente novamente.';

  @override
  String get toast_members_added => 'Membros adicionados';

  @override
  String get toast_member_added => 'Membro adicionado.';

  @override
  String get toast_members_add_error =>
      'Falha ao adicionar membros. Por favor, tente novamente.';

  @override
  String get toast_member_add_error =>
      'Falha ao adicionar membro. Por favor, tente novamente.';

  @override
  String get toast_member_removed => 'Membro removido.';

  @override
  String get toast_member_remove_error =>
      'Falha ao remover membro. Por favor, tente novamente.';

  @override
  String get toast_member_promoted => 'Membro promovido.';

  @override
  String get toast_member_promote_error =>
      'Falha ao promover membro. Por favor, tente novamente.';

  @override
  String get toast_member_demoted => 'Membro rebaixado.';

  @override
  String get toast_member_demote_error =>
      'Falha ao rebaixar membro. Por favor, tente novamente.';

  @override
  String get toast_user_banned => 'Usuário banido.';

  @override
  String get toast_user_ban_error =>
      'Falha ao banir usuário. Por favor, tente novamente.';

  @override
  String get toast_user_reported => 'Usuário reportado.';

  @override
  String get toast_user_unreported => 'Reporte de usuário removido.';

  @override
  String get toast_user_report_error =>
      'Falha ao reportar/desreportar usuário. Por favor, tente novamente.';

  @override
  String get toast_user_muted => 'Usuário silenciado.';

  @override
  String get toast_user_mute_error =>
      'Falha ao silenciar usuário. Por favor, tente novamente.';

  @override
  String get toast_user_unmuted => 'Usuário dessilenciado.';

  @override
  String get toast_user_unmute_error =>
      'Falha ao dessilenciar usuário. Por favor, tente novamente.';

  @override
  String get user_list_add => 'Adicionar';

  @override
  String get user_list_you => 'Você';

  @override
  String get user_list_you_suffix => ' (Você)';

  @override
  String get chat_new_conversation => 'Nova conversa';

  @override
  String get search_minimum_characters =>
      'Comece sua pesquisa digitando\n pelo menos 3 letras';

  @override
  String get message_sending => 'Enviando...';

  @override
  String get message_not_sent => 'Sua mensagem não foi enviada';

  @override
  String get message_resend => 'Reenviar';

  @override
  String get general_error_title => 'Erro';

  @override
  String get general_error_message => 'Ocorreu um erro';

  @override
  String get chat_message_video_sent => 'Enviou um vídeo';

  @override
  String get chat_message_photo_sent => 'Enviou uma foto';

  @override
  String get chat_message_no_content => 'Sem conteúdo de mensagem';

  @override
  String get chat_archived_label => 'Arquivado';

  @override
  String get chat_add_member => 'Adicionar membro';

  @override
  String get chat_promote_moderator => 'Promover a moderador';

  @override
  String get chat_demote_moderator => 'Rebaixar de moderador';

  @override
  String get chat_mute_user => 'Silenciar usuário';

  @override
  String get chat_unmute_user => 'Desativar silêncio do usuário';

  @override
  String get chat_ban_user => 'Banir usuário';

  @override
  String get chat_unban_user => 'Desbanir usuário';

  @override
  String get chat_remove_member => 'Remover do grupo';

  @override
  String get reaction_tap_to_remove => 'Toque para remover reação';

  @override
  String get image_load_error =>
      'Não foi possível carregar a imagem. Por favor, tente novamente.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get community_title => 'Comunidade';

  @override
  String get tab_newsfeed => 'Feed de notícias';

  @override
  String get tab_explore => 'Explorar';

  @override
  String get tab_my_communities => 'Minhas Comunidades';

  @override
  String get global_search_hint => 'Pesquisar comunidade e usuário';

  @override
  String get search_my_community_hint => 'Buscar minha comunidade';

  @override
  String get search_no_results => 'Nenhum resultado encontrado';

  @override
  String get title_communities => 'Comunidades';

  @override
  String get title_users => 'Usuários';

  @override
  String get general_cancel => 'Cancelar';

  @override
  String get general_ok => 'OK';

  @override
  String get general_confirm => 'Confirmar';

  @override
  String get general_featured => 'Destaque';

  @override
  String get profile_followers => 'Seguidores';

  @override
  String get profile_following => 'Seguindo';

  @override
  String get profile_posts => 'Publicações';

  @override
  String get post_create => 'Criar Publicação';

  @override
  String get post_edit => 'Editar Publicação';

  @override
  String get post_create_hint => 'O que você quer compartilhar?';

  @override
  String get post_delete => 'Excluir Publicação';

  @override
  String get post_delete_description =>
      'Esta publicação será excluída permanentemente.';

  @override
  String get post_delete_confirmation => 'Excluir Publicação?';

  @override
  String get post_delete_confirmation_description =>
      'Você quer excluir sua publicação?';

  @override
  String get post_report => 'Denunciar publicação';

  @override
  String get post_unreport => 'Remover denúncia';

  @override
  String get post_like => 'Curtir';

  @override
  String get post_comment => 'Comentar';

  @override
  String get post_share => 'Compartilhar';

  @override
  String get post_discard => 'Descartar esta publicação?';

  @override
  String get post_discard_description =>
      'A publicação será excluída permanentemente. Não pode ser desfeito.';

  @override
  String get post_write_comment => 'Escreva um comentário...';

  @override
  String get poll_duration => 'Duração da enquete';

  @override
  String get poll_duration_hint =>
      'Você sempre pode fechar a enquete antes do tempo definido.';

  @override
  String get poll_custom_edn_date => 'Data de término personalizada';

  @override
  String get poll_close => 'Fechar enquete';

  @override
  String get poll_close_description =>
      'Esta enquete está fechada. Você não pode mais votar.';

  @override
  String get poll_vote => 'Votar';

  @override
  String get poll_results => 'Ver resultados';

  @override
  String get poll_back_to_vote => 'Voltar para votar';

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
      zero: 'Nenhum voto',
    );
    return '$_temp0';
  }

  @override
  String poll_see_more_options(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count mais opções',
      one: 'Ver 1 mais opção',
    );
    return '$_temp0';
  }

  @override
  String get poll_see_full_results => 'Ver Resultados Completos';

  @override
  String get poll_voted => 'Votado por você';

  @override
  String get poll_and_you => ' e você';

  @override
  String get poll_remaining_time => 'restante';

  @override
  String get poll_vote_error =>
      'Falha ao votar na enquete. Por favor, tente novamente.';

  @override
  String get poll_ended => 'Encerrada';

  @override
  String get poll_single_choice => 'Selecione uma opção';

  @override
  String get poll_multiple_choice => 'Selecione uma ou mais opções';

  @override
  String poll_options_description(int minOptions) {
    return 'A enquete deve conter pelo menos $minOptions opções.';
  }

  @override
  String get poll_question => 'Pergunta da enquete';

  @override
  String get poll_question_hint => 'Qual é a sua pergunta da enquete?';

  @override
  String get comment_create_hint => 'Diga algo legal...';

  @override
  String get comment_reply => 'Responder';

  @override
  String get comment_reply_to => 'Respondendo a ';

  @override
  String comment_view_reply_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count respostas',
      one: 'Ver 1 resposta',
    );
    return '$_temp0';
  }

  @override
  String get comment_report => 'Denunciar comentário';

  @override
  String get comment_unreport => 'Remover denúncia';

  @override
  String get comment_reply_report => 'Denunciar resposta';

  @override
  String get comment_reply_unreport => 'Remover denúncia';

  @override
  String get comment_edit => 'Editar comentário';

  @override
  String get comment_reply_edit => 'Editar resposta';

  @override
  String get comment_delete => 'Excluir comentário';

  @override
  String get comment_reply_delete => 'Excluir resposta';

  @override
  String comment_delete_description(String content) {
    return 'Este $content será excluído permanentemente.';
  }

  @override
  String get comment_create_error_ban_word =>
      'Seu comentário contém uma palavra inadequada. Por favor, revise e exclua.';

  @override
  String get comment_create_error_story_deleted =>
      'Esta história não está mais disponível';

  @override
  String get community_create_success_message =>
      'Comunidade criada com sucesso.';

  @override
  String get community_create_error_message =>
      'Falha ao criar comunidade. Por favor, tente novamente.';

  @override
  String get community_update_success_message =>
      'Comunidade atualizada com sucesso.';

  @override
  String get community_update_error_message =>
      'Falha ao salvar o perfil da comunidade. Por favor, tente novamente.';

  @override
  String get community_leave_success_message =>
      'Você saiu da comunidade com sucesso.';

  @override
  String get community_leave_error_message => 'Falha ao sair da comunidade.';

  @override
  String get community_close_success_message =>
      'Comunidade fechada com sucesso.';

  @override
  String get community_close_error_message => 'Falha ao fechar a comunidade.';

  @override
  String get community_close => 'Fechar comunidade?';

  @override
  String get community_close_description =>
      'Todos os membros serão removidos da comunidade. Todas as publicações, mensagens, reações e mídias compartilhadas na comunidade serão excluídas. Isso não pode ser desfeito.';

  @override
  String get community_join => 'Entrar';

  @override
  String get community_joined => 'Entrou';

  @override
  String get community_recommended_for_you => 'Recomendado para você';

  @override
  String get community_trending_now => 'Em alta agora';

  @override
  String get community_placeholder_members => '1.2K membros';

  @override
  String get community_leave => 'Sair da comunidade';

  @override
  String get community_leave_description =>
      'Sair da comunidade. Você não poderá mais publicar e interagir nesta comunidade.';

  @override
  String get community_create => 'Criar Comunidade';

  @override
  String get community_name => 'Nome da comunidade';

  @override
  String get community_name_hint => 'Nomeie sua comunidade';

  @override
  String get community_description_hint => 'Digite a descrição';

  @override
  String get community_edit => 'Editar Comunidade';

  @override
  String get community_members => 'Membros';

  @override
  String get community_private => 'Privada';

  @override
  String get community_public => 'Pública';

  @override
  String get community_public_description =>
      'Qualquer pessoa pode entrar, visualizar e pesquisar as publicações nesta comunidade.';

  @override
  String get community_private_description =>
      'Apenas membros convidados pelos moderadores podem entrar, visualizar e pesquisar as publicações nesta comunidade.';

  @override
  String get community_about => 'Sobre';

  @override
  String get categories_title => 'Categorias';

  @override
  String get category_hint => 'Selecione a categoria';

  @override
  String get category_select_title => 'Selecionar Categoria';

  @override
  String get category_add => 'Adicionar Categoria';

  @override
  String get community_pending_posts => 'Publicações Pendentes';

  @override
  String get commnuity_pending_post_reviewing =>
      'Suas publicações estão pendentes de revisão';

  @override
  String commnuity_pending_post_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicações precisam de aprovação',
      one: '$count publicação precisa de aprovação',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Solicitações pendentes',
      one: 'Solicitação pendente',
    );
    return '$_temp0';
  }

  @override
  String community_pending_request_message(String displayCount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicações requerem',
      one: 'publicação requer',
    );
    return '$displayCount $_temp0 aprovação';
  }

  @override
  String get community_basic_info => 'Informações Básicas';

  @override
  String get community_discard_confirmation => 'Sair sem terminar?';

  @override
  String get community_discard_description =>
      'Seu progresso não será salvo e sua comunidade não será criada.';

  @override
  String get message_send => 'Enviar';

  @override
  String get message_typing => 'está digitando...';

  @override
  String get message_placeholder => 'Digite uma mensagem...';

  @override
  String get message_deleted => 'Esta mensagem foi excluída';

  @override
  String get message_failed_to_send => 'Falha ao enviar a mensagem.';

  @override
  String get message_reply_you_to_yourself => 'Você respondeu a si mesmo';

  @override
  String get message_reply_to_you => 'Respondeu a você';

  @override
  String get message_reply_you => 'Você respondeu';

  @override
  String get message_reply_to_themself => 'Respondeu a si mesmo';

  @override
  String get message_reply_you_to_deleted =>
      'Você respondeu a uma mensagem excluída';

  @override
  String get message_reply_to_deleted => 'Respondeu a uma mensagem excluída';

  @override
  String get message_unknown_user => 'Desconhecido';

  @override
  String get settings_title => 'Configurações';

  @override
  String get settings_notifications => 'Notificações';

  @override
  String get settings_new_posts => 'Novas publicações';

  @override
  String get settings_new_posts_description =>
      'Receba notificações quando alguém criar novas publicações nesta comunidade.';

  @override
  String get settings_react_posts => 'Reações às publicações';

  @override
  String get settings_react_posts_description =>
      'Receba notificações quando alguém reagir às suas publicações nesta comunidade.';

  @override
  String get settings_react_comments => 'Reações aos comentários';

  @override
  String get settings_react_comments_description =>
      'Receba notificações quando alguém curtir seu comentário nesta comunidade.';

  @override
  String get settings_new_comments => 'Novos comentários';

  @override
  String get settings_new_comments_description =>
      'Receba notificações quando alguém comentar em sua publicação nesta comunidade.';

  @override
  String get settings_new_replies => 'Respostas';

  @override
  String get settings_new_replies_description =>
      'Receba notificações quando alguém comentar em seus comentários nesta comunidade.';

  @override
  String get settings_allow_stories_comments =>
      'Permitir comentários nas histórias da comunidade';

  @override
  String get settings_allow_stories_comments_description =>
      'Ative para receber comentários nas histórias desta comunidade.';

  @override
  String get settings_new_stories => 'Novas histórias';

  @override
  String get settings_new_stories_description =>
      'Receba notificações quando alguém criar uma nova história nesta comunidade.';

  @override
  String get settings_story_reactions => 'Reações às histórias';

  @override
  String get settings_story_reactions_description =>
      'Receba notificações quando alguém reagir à sua história nesta comunidade.';

  @override
  String get settings_story_comments => 'Comentários nas histórias';

  @override
  String get settings_story_comments_description =>
      'Receba notificações quando alguém comentar em sua história nesta comunidade.';

  @override
  String get settings_everyone => 'Todos';

  @override
  String get settings_only_moderators => 'Apenas moderadores';

  @override
  String get settings_only_admins => 'Apenas administradores podem publicar';

  @override
  String get settings_privacy => 'Privacidade';

  @override
  String get settings_permissions => 'Permissões da comunidade';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_leave_confirmation => 'Sair sem terminar?';

  @override
  String get settings_leave_description =>
      'As alterações que você fez podem não ser salvas.';

  @override
  String get settings_privacy_confirmation =>
      'Alterar as configurações de privacidade da comunidade?';

  @override
  String get settings_privacy_description =>
      'Esta comunidade tem publicações destacadas globalmente. Alterar a comunidade de pública para privada removerá essas publicações de serem destacadas globalmente.';

  @override
  String get general_add => 'Adicionar';

  @override
  String get general_loading => 'Carregando...';

  @override
  String get general_leave => 'Sair';

  @override
  String get general_error => 'Ops, algo deu errado';

  @override
  String get general_edited => 'Editado';

  @override
  String get general_edited_suffix => ' (editado)';

  @override
  String get general_keep_editing => 'Continuar editando';

  @override
  String get general_discard => 'Descartar';

  @override
  String get general_moderator => 'Moderador';

  @override
  String get general_save => 'Salvar';

  @override
  String get general_delete => 'Excluir';

  @override
  String get general_edit => 'Editar';

  @override
  String get general_close => 'Fechar';

  @override
  String get general_done => 'Concluído';

  @override
  String get general_post => 'Publicar';

  @override
  String get general_comments => 'Comentários';

  @override
  String get general_story => 'História';

  @override
  String get general_stories => 'Histórias';

  @override
  String get general_poll => 'Enquete';

  @override
  String get general_optional => 'Opcional';

  @override
  String get general_on => 'Ativado';

  @override
  String get general_off => 'Desativado';

  @override
  String get settings_allow_notification => 'Permitir Notificação';

  @override
  String get settings_allow_notification_description =>
      'Ative para receber notificações push desta comunidade.';

  @override
  String get general_reported => 'denunciado';

  @override
  String get general_unreported => 'não denunciado';

  @override
  String get general_see_more => '...Ver mais';

  @override
  String get general_camera => 'Câmera';

  @override
  String get general_photo => 'Foto';

  @override
  String get general_video => 'Vídeo';

  @override
  String get general_posting => 'Publicando';

  @override
  String get general_my_timeline => 'Minha Linha do Tempo';

  @override
  String get general_options => 'Opções';

  @override
  String get general_go_back => 'Voltar';

  @override
  String get post_unavailable_title => 'Algo deu errado';

  @override
  String get post_unavailable_description =>
      'O conteúdo que você está procurando não está disponível.';

  @override
  String get comment_deleted_message => 'Este comentário foi excluído';

  @override
  String get comment_reply_deleted_message => 'Esta resposta foi excluída';

  @override
  String get post_edit_globally_featured =>
      'Editar publicação destacada globalmente?';

  @override
  String get post_edit_globally_featured_description =>
      'A publicação que você está editando foi destacada globalmente. Se você editar sua publicação, ela precisará ser reaprovação e não será mais destacada globalmente.';

  @override
  String post_like_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count curtidas',
      one: '1 curtida',
    );
    return '$_temp0';
  }

  @override
  String post_comment_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentários',
      one: '1 comentário',
    );
    return '$_temp0';
  }

  @override
  String get post_reported => 'Publicação denunciada.';

  @override
  String get post_unreported => 'Denúncia removida.';

  @override
  String profile_followers_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seguidores',
      one: '1 seguidor',
      zero: 'Nenhum seguidor',
    );
    return '$_temp0';
  }

  @override
  String community_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '1 membro',
      zero: 'Nenhum membro',
    );
    return '$_temp0';
  }

  @override
  String profile_posts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'publicações',
      one: 'publicação',
    );
    return '$_temp0';
  }

  @override
  String profile_members_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'membros',
      one: 'membro',
    );
    return '$_temp0';
  }

  @override
  String get user_block => 'Bloquear usuário';

  @override
  String get user_unblock => 'Desbloquear usuário';

  @override
  String get error_delete_post =>
      'Falha ao excluir a publicação. Por favor, tente novamente.';

  @override
  String get error_leave_community => 'Não foi possível sair da comunidade';

  @override
  String get error_leave_community_description =>
      'Você é o único moderador deste grupo. Para sair da comunidade, nomeie outros membros para o cargo de moderador';

  @override
  String get error_close_community => 'Não foi possível fechar a comunidade';

  @override
  String get error_close_community_description =>
      'Algo deu errado. Por favor, tente novamente mais tarde.';

  @override
  String get error_max_upload_reached => 'Limite máximo de upload atingido';

  @override
  String error_max_upload_image_reached_description(int maxUploads) {
    return 'Você atingiu o limite de upload de $maxUploads imagens. Quaisquer imagens adicionais não serão salvas.';
  }

  @override
  String error_max_upload_videos_reached_description(int maxUploads) {
    return 'Você atingiu o limite de upload de $maxUploads vídeos. Quaisquer vídeos adicionais não serão salvos.';
  }

  @override
  String get error_edit_post =>
      'Falha ao editar a publicação. Por favor, tente novamente.';

  @override
  String get error_create_post =>
      'Falha ao criar a publicação. Por favor, tente novamente.';

  @override
  String error_max_poll_characters(int maxQuestionLength) {
    return 'A pergunta da enquete não pode exceder $maxQuestionLength caracteres.';
  }

  @override
  String error_max_poll_option_characters(int maxQuestionLength) {
    return 'A opção da enquete não pode exceder $maxQuestionLength caracteres.';
  }

  @override
  String get error_create_poll =>
      'Falha ao criar a enquete. Por favor, tente novamente.';

  @override
  String get error_poll_end_time_must_be_future =>
      'O horário de término da enquete deve estar no futuro. Selecione uma data e hora válidas.';

  @override
  String get error_message_too_long_title => 'Não é possível enviar a mensagem';

  @override
  String get error_message_too_long_description =>
      'Sua mensagem é muito longa. Por favor, encurte sua mensagem e tente novamente.';

  @override
  String get user_profile_unknown_name => 'Desconhecido';

  @override
  String get user_profile_deleted_name => 'Usuário excluído';

  @override
  String get community_all_members => 'Todos os membros';

  @override
  String get community_moderators => 'Moderadores';

  @override
  String get community_search_member_hint => 'Buscar membro';

  @override
  String get community_promote_moderator => 'Promover a moderador';

  @override
  String get community_demote_member => 'Rebaixar para membro';

  @override
  String get community_remove_member => 'Remover da comunidade';

  @override
  String get user_report => 'Denunciar usuário';

  @override
  String get user_unreport => 'Remover denúncia de usuário';

  @override
  String get feed_no_videos => 'Ainda sem vídeos';

  @override
  String get feed_no_photos => 'Ainda sem fotos';

  @override
  String get feed_no_pinned_posts => 'Ainda sem publicação fixada';

  @override
  String get feed_no_posts => 'Ainda sem publicações';

  @override
  String get member_add => 'Adicionar membro';

  @override
  String get search_user_hint => 'Buscar usuário';

  @override
  String get profile_edit => 'Editar Perfil';

  @override
  String get profile_update_success => 'Perfil atualizado com sucesso!';

  @override
  String get profile_update_failed =>
      'Falha ao salvar seu perfil. Por favor, tente novamente.';

  @override
  String get community_post_permission => 'Permissão de publicação';

  @override
  String get community_story_comments => 'Comentários em histórias';

  @override
  String get community_setting_close_label => 'Fechar comunidade';

  @override
  String get community_setting_close_description =>
      'Fechar esta comunidade removerá a página da comunidade e todo o seu conteúdo e comentários.';

  @override
  String get community_post_permission_title_label =>
      'Quem pode publicar nesta comunidade';

  @override
  String get community_post_permission_description_label =>
      'Você pode controlar quem pode criar publicações em sua comunidade.';

  @override
  String get post_item_bottom_nonmember_label =>
      'Entre na comunidade para interagir com todas as publicações';

  @override
  String get notification_turn_on_success => 'Notificação ativada';

  @override
  String get notification_turn_on_error =>
      'Falha ao ativar notificação. Por favor, tente novamente.';

  @override
  String get notification_turn_off_success => 'Notificação desativada';

  @override
  String get notification_turn_off_error =>
      'Falha ao desativar notificação. Por favor, tente novamente.';

  @override
  String get user_report_success => 'Usuário denunciado.';

  @override
  String get user_report_error =>
      'Falha ao denunciar usuário. Por favor, tente novamente.';

  @override
  String get user_unreport_success => 'Denúncia de usuário removida.';

  @override
  String get user_unreport_error =>
      'Falha ao remover denúncia de usuário. Por favor, tente novamente.';

  @override
  String get user_block_success => 'Usuário bloqueado.';

  @override
  String get user_block_error =>
      'Falha ao bloquear usuário. Por favor, tente novamente.';

  @override
  String get user_unblock_success => 'Usuário desbloqueado.';

  @override
  String get user_unblock_error =>
      'Falha ao desbloquear usuário. Por favor, tente novamente.';

  @override
  String get search_no_members_found => 'Nenhum membro encontrado';

  @override
  String get moderator_promotion_title => 'Promoção de moderador';

  @override
  String get moderator_promotion_description =>
      'Tem certeza de que deseja promover este membro a Moderador? Eles terão acesso a todos os recursos de moderador.';

  @override
  String get moderator_promote_button => 'Promover';

  @override
  String get moderator_demotion_title => 'Rebaixamento de moderador';

  @override
  String get moderator_demotion_description =>
      'Tem certeza de que deseja rebaixar este Moderador? Eles perderão acesso a todos os recursos de moderador.';

  @override
  String get moderator_demote_button => 'Rebaixar';

  @override
  String get member_removal_confirm_title => 'Confirmar remoção';

  @override
  String get member_removal_confirm_description =>
      'Tem certeza de que deseja remover este membro do grupo? Eles serão informados de sua remoção.';

  @override
  String get member_remove_button => 'Remover';

  @override
  String get user_ban_confirm_title => 'Confirmar banimento';

  @override
  String get user_ban_confirm_description =>
      'Tem certeza de que deseja banir este usuário? Eles serão removidos do grupo e não poderão encontrá-lo ou entrar novamente a menos que sejam desbanidos.';

  @override
  String get user_ban_button => 'Banir';

  @override
  String get member_add_success =>
      'Membro adicionado com sucesso a esta comunidade.';

  @override
  String get member_add_error =>
      'Falha ao adicionar membro. Por favor, tente novamente.';

  @override
  String get moderator_promote_success => 'Promovido a moderador com sucesso.';

  @override
  String get moderator_promote_error =>
      'Falha ao promover membro. Por favor, tente novamente.';

  @override
  String get moderator_demote_success => 'Rebaixado para membro com sucesso.';

  @override
  String get moderator_demote_error =>
      'Falha ao rebaixar membro. Por favor, tente novamente.';

  @override
  String get member_remove_success => 'Membro removido desta comunidade.';

  @override
  String get member_remove_error =>
      'Falha ao remover membro. Por favor, tente novamente.';

  @override
  String get user_follow_success => 'Usuário seguido.';

  @override
  String get user_follow_error => 'Ops, algo deu errado.';

  @override
  String get user_unfollow_success => 'Deixou de seguir usuário.';

  @override
  String get user_unfollow_error => 'Ops, algo deu errado.';

  @override
  String get post_target_selection_title => 'Publicar em';

  @override
  String get user_feed_blocked_title => 'Você bloqueou este usuário';

  @override
  String get user_feed_blocked_description =>
      'Desbloquear para ver suas publicações.';

  @override
  String get user_feed_private_title => 'Esta conta é privada';

  @override
  String get user_feed_private_description =>
      'Siga este usuário para ver suas publicações.';

  @override
  String get timestamp_just_now => 'Agora mesmo';

  @override
  String get timestamp_now => 'agora';

  @override
  String get chat_notification_turn_on => 'Ativar notificações';

  @override
  String get chat_notification_turn_off => 'Desativar notificações';

  @override
  String get chat_block_user_title => 'Bloquear usuário?';

  @override
  String chat_block_user_description(String displayName) {
    return '$displayName não poderá enviar mensagens para você. Eles não serão notificados de que você os bloqueou.';
  }

  @override
  String get chat_unblock_user_title => 'Desbloquear usuário?';

  @override
  String chat_unblock_user_description(String displayName) {
    return '$displayName agora poderá enviar mensagens para você. Eles não serão notificados de que você os desbloqueou.';
  }

  @override
  String get chat_message_photo => 'Enviar uma foto';

  @override
  String get chat_message_video => 'Enviar um vídeo';

  @override
  String get user_follow_request_new => 'Novas solicitações de seguir';

  @override
  String user_follow_request_approval(String count) {
    return '$count solicitações precisam de sua aprovação';
  }

  @override
  String get user_unfollow => 'Deixar de seguir';

  @override
  String get user_follow_unable_title => 'Não foi possível seguir este usuário';

  @override
  String get user_follow_unable_description =>
      'Ops! algo deu errado. Por favor, tente novamente mais tarde.';

  @override
  String get user_follow => 'Seguir';

  @override
  String get user_follow_cancel => 'Cancelar Solicitação';

  @override
  String get user_following => 'Seguindo';

  @override
  String get user_block_confirm_title => 'Bloquear usuário?';

  @override
  String user_block_confirm_description(String displayName) {
    return '$displayName não poderá ver publicações e comentários que você criou. Eles não serão notificados de que você os bloqueou.';
  }

  @override
  String get user_block_confirm_button => 'Bloquear';

  @override
  String get user_unblock_confirm_title => 'Desbloquear usuário?';

  @override
  String user_unblock_confirm_description(String displayName) {
    return '$displayName agora poderá ver publicações e comentários que você criou. Eles não serão notificados de que você os desbloqueou.';
  }

  @override
  String get user_unblock_confirm_button => 'Desbloquear';

  @override
  String get user_unfollow_confirm_title => 'Deixar de seguir este usuário?';

  @override
  String get user_unfollow_confirm_description =>
      'Se você mudar de ideia, terá que solicitar para segui-los novamente.';

  @override
  String get user_unfollow_confirm_button => 'Deixar de seguir';

  @override
  String get category_default_title => 'Categoria';

  @override
  String get community_empty_state => 'Ainda sem comunidade';

  @override
  String get community_pending_requests_title => 'Solicitações Pendentes';

  @override
  String get community_pending_requests_empty_title =>
      'Sem solicitações pendentes disponíveis';

  @override
  String get community_pending_requests_empty_description =>
      'Ative a revisão de publicações ou aprovação de entrada nas configurações da comunidade para gerenciar solicitações.';

  @override
  String get community_join_requests_coming_soon =>
      'Funcionalidade de solicitações de entrada em breve';

  @override
  String get community_pending_posts_warning =>
      'Recusar publicação pendente excluirá permanentemente a publicação selecionada da comunidade.';

  @override
  String get community_pending_posts_empty => 'Sem publicações pendentes';

  @override
  String get community_pending_post_accept => 'Aceitar';

  @override
  String get community_pending_post_decline => 'Recusar';

  @override
  String get community_pending_post_delete_success => 'Publicação excluída.';

  @override
  String get community_pending_post_delete_error =>
      'Falha ao excluir publicação. Por favor, tente novamente.';

  @override
  String get community_pending_post_approve_success => 'Publicação aceita.';

  @override
  String get community_pending_post_approve_error =>
      'Falha ao aceitar publicação. Esta publicação foi revisada por outro moderador.';

  @override
  String get community_pending_post_decline_success => 'Publicação recusada.';

  @override
  String get community_pending_post_decline_error =>
      'Falha ao recusar publicação. Esta publicação foi revisada por outro moderador.';

  @override
  String poll_option_hint(int optionNumber) {
    return 'Opção $optionNumber';
  }

  @override
  String get poll_add_option => 'Adicionar opção';

  @override
  String get poll_multiple_selection_title => 'Seleção múltipla';

  @override
  String get poll_multiple_selection_description =>
      'Permitir que os participantes votem em mais de uma opção.';

  @override
  String poll_ends_on(String endDate) {
    return 'Termina em $endDate';
  }

  @override
  String get poll_ends_on_label => 'Termina em';

  @override
  String get poll_select_date => 'Selecionar Data';

  @override
  String get poll_select_time => 'Selecionar Hora';

  @override
  String poll_duration_days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get poll_time_hour => 'Hora';

  @override
  String get poll_time_minute => 'Minuto';

  @override
  String get profile_edit_display_name => 'Nome de exibição';

  @override
  String get profile_edit_about => 'Sobre';

  @override
  String get profile_edit_unsupported_image_title =>
      'Tipo de imagem não suportado';

  @override
  String get profile_edit_unsupported_image_description =>
      'Por favor, envie uma imagem PNG ou JPG.';

  @override
  String get profile_edit_inappropriate_image_title => 'Imagem inapropriada';

  @override
  String get profile_edit_inappropriate_image_description =>
      'Por favor, escolha uma imagem diferente para enviar.';

  @override
  String get profile_edit_unsaved_changes_title => 'Alterações não salvas';

  @override
  String get profile_edit_unsaved_changes_description =>
      'Tem certeza de que deseja descartar as alterações? Elas serão perdidas quando você sair desta página.';

  @override
  String get chat_title => 'Chat';

  @override
  String get chat_tab_all => 'Todos';

  @override
  String get chat_tab_direct => 'Direto';

  @override
  String get chat_tab_groups => 'Grupos';

  @override
  String get chat_waiting_for_network => 'Aguardando conexão de rede...';

  @override
  String get chat_direct_chat => 'Chat direto';

  @override
  String get chat_group_chat => 'Chat em grupo';

  @override
  String get chat_archived => 'Arquivado';

  @override
  String get message_editing_message => 'Editando mensagem';

  @override
  String get message_replying_yourself => 'você mesmo';

  @override
  String get message_replied_message => 'Mensagem respondida';

  @override
  String message_replying_to(String displayName) {
    return 'Respondendo a $displayName';
  }

  @override
  String get message_media => 'Mídia';

  @override
  String get chat_loading => 'Carregando chat...';

  @override
  String get chat_blocked_message =>
      'Você não pode enviar mensagens para esta pessoa.';

  @override
  String get chat_notifications_disabled =>
      'Você desativou as notificações para chat';

  @override
  String get chat_archive => 'Arquivar';

  @override
  String get chat_unarchive => 'Desarquivar';

  @override
  String get chat_message_deleted => 'Esta mensagem foi excluída';

  @override
  String get chat_message_no_preview =>
      'Sem visualização disponível para este tipo de mensagem';

  @override
  String get chat_no_message_yet => 'Ainda sem mensagens';

  @override
  String get general_search_hint => 'Pesquisar';

  @override
  String get chat_archived_empty_title => 'Sem chats arquivados';

  @override
  String get chat_archived_title => 'Chats arquivados';

  @override
  String get toast_chat_archived => 'Chat arquivado.';

  @override
  String get toast_chat_unarchived => 'Chat desarquivado.';

  @override
  String get toast_chat_archive_error =>
      'Falha ao arquivar o chat. Por favor, tente novamente';

  @override
  String get toast_chat_unarchive_error =>
      'Falha ao desarquivar o chat. Por favor, tente novamente';

  @override
  String get chat_archive_limit_title => 'Muitos chats arquivados';

  @override
  String get chat_archive_limit_message =>
      'Você pode arquivar no máximo 100 listas de chat.';

  @override
  String get chat_empty_title => 'Ainda sem conversas';

  @override
  String get chat_empty_description => 'Vamos criar um chat para começar.';

  @override
  String get chat_create_new => 'Criar novo chat';

  @override
  String get chat_group_profile_title => 'Perfil do grupo';

  @override
  String get chat_group_profile_error => 'Erro ao carregar perfil';

  @override
  String get chat_group_name_hint => 'Digite o nome do grupo';

  @override
  String get chat_group_name_placeholder => 'Nomeie seu grupo';

  @override
  String get chat_member_permissions_title => 'Permissões de membros';

  @override
  String get chat_member_label => 'Membro';

  @override
  String get chat_select_member_error =>
      'Por favor, selecione pelo menos um usuário';

  @override
  String get message_report_details_hint =>
      'Compartilhe mais detalhes sobre este problema';

  @override
  String get chat_search_tab_chats => 'Chats';

  @override
  String get chat_search_tab_messages => 'Mensagens';

  @override
  String get search_minimum_chars =>
      'Comece sua pesquisa digitando\npelo menos 3 letras';

  @override
  String get permission_camera_title => 'Permitir acesso à sua câmera';

  @override
  String get permission_camera_detail =>
      'Isso permite que o aplicativo tire fotos e grave vídeos da câmera do seu dispositivo.';

  @override
  String get permission_microphone_title => 'Permitir acesso ao seu microfone';

  @override
  String get permission_microphone_detail =>
      'Isso permite que o aplicativo grave áudio para vídeos do microfone do seu dispositivo.';

  @override
  String get permission_open_settings => 'Abrir configurações';

  @override
  String get general_copy => 'Copiar';

  @override
  String get message_report => 'Denunciar';

  @override
  String get message_unreport => 'Remover Denúncia';

  @override
  String get toast_message_copied => 'Copiado.';

  @override
  String get toast_message_reported => 'Mensagem denunciada.';

  @override
  String get toast_message_unreported => 'Denúncia de mensagem retirada.';

  @override
  String get toast_message_report_error =>
      'Falha ao denunciar a mensagem. Por favor, tente novamente.';

  @override
  String get toast_message_unreport_error =>
      'Falha ao retirar a denúncia da mensagem. Por favor, tente novamente.';

  @override
  String get toast_message_delete_error => 'Falha ao excluir a mensagem.';

  @override
  String get toast_permission_denied => 'Permissão negada.';

  @override
  String get toast_photo_saved => 'Foto salva.';

  @override
  String get toast_photo_save_error => 'Falha ao salvar a imagem.';

  @override
  String get toast_video_saved => 'Vídeo salvo.';

  @override
  String get toast_video_save_error => 'Falha ao salvar o vídeo.';

  @override
  String get message_delete_title => 'Excluir esta mensagem?';

  @override
  String get message_delete_description =>
      'Esta mensagem também será removida dos dispositivos dos seus amigos.';

  @override
  String get chat_create_success => 'Grupo de chat criado.';

  @override
  String get chat_create_error => 'Falha ao criar grupo';

  @override
  String get chat_create_error_retry =>
      'Falha ao criar grupo de chat. Por favor, tente novamente.';

  @override
  String get chat_create_title => 'Novo Grupo';

  @override
  String get chat_create_button => 'Criar';

  @override
  String get chat_group_name_label => 'Nome do grupo';

  @override
  String get chat_group_name_optional => '(Opcional)';

  @override
  String get chat_group_name_required => '(Obrigatório)';

  @override
  String get chat_privacy_public => 'Público';

  @override
  String get chat_privacy_public_desc =>
      'Qualquer pessoa pode encontrar o grupo através da pesquisa e participar da conversa.';

  @override
  String get chat_privacy_private => 'Privado';

  @override
  String get chat_privacy_private_desc =>
      'O grupo está oculto nas pesquisas e só é acessível por convite dos moderadores.';

  @override
  String get chat_privacy_warning =>
      'Certifique-se de escolher a configuração de privacidade correta para o seu grupo, pois ela não pode ser alterada posteriormente.';

  @override
  String get chat_select_member_title => 'Novo grupo';

  @override
  String get general_next => 'Próximo';

  @override
  String get settings_group_settings => 'Configurações do grupo';

  @override
  String get settings_group_settings_section => 'Configurações do grupo';

  @override
  String get settings_group_profile => 'Perfil do grupo';

  @override
  String get settings_group_notifications => 'Notificações do grupo';

  @override
  String get settings_member_permissions => 'Permissões de membros';

  @override
  String get settings_all_members => 'Todos os membros';

  @override
  String get settings_banned_users => 'Usuários banidos';

  @override
  String get banned_users_empty_state => 'Nada para ver aqui ainda';

  @override
  String get user_unban_confirm_title => 'Confirmar desbloqueio';

  @override
  String get user_unban_confirm_description =>
      'Tem certeza de que deseja desbloquear este usuário? Eles poderão voltar a participar do grupo.';

  @override
  String get user_unban_button => 'Desbloquear';

  @override
  String get toast_user_unbanned => 'Usuário desbanido.';

  @override
  String get toast_user_unban_error =>
      'Falha ao desbanir o usuário. Por favor, tente novamente.';

  @override
  String get settings_your_preferences => 'Suas preferências';

  @override
  String get general_notifications_lowercase => 'notificações';

  @override
  String get chat_leave_group => 'Sair do grupo';

  @override
  String get chat_leave_group_title => 'Sair do grupo';

  @override
  String get chat_leave_group_confirm =>
      'Se você sair deste grupo, não verá mais novas atividades nem poderá participar neste grupo.';

  @override
  String get chat_leave_group_last_mod_title => 'Você é o último moderador';

  @override
  String get chat_leave_group_last_mod_message =>
      'Você deve promover outro membro a moderador antes de sair.';

  @override
  String get chat_promote_member => 'Promover membro';

  @override
  String get notification_default_mode => 'Modo padrão';

  @override
  String get notification_default_mode_desc =>
      'Por padrão, os membros desta comunidade receberão notificações, mas podem escolher desativá-las.';

  @override
  String get notification_silent_mode => 'Modo silencioso';

  @override
  String get notification_silent_mode_desc =>
      'Sem notificações para todos neste canal. Os membros não podem ativar notificações no canal.';

  @override
  String get notification_subscribe_mode => 'Modo assinatura';

  @override
  String get notification_subscribe_mode_desc =>
      'Todos os membros têm a opção de receber notificações, mas precisam ativá-las. Por padrão, as notificações estão desativadas para cada membro.';

  @override
  String get notification_preference_title => 'Preferência de notificações';

  @override
  String get notification_allow_notifications => 'Permitir notificações';

  @override
  String get notification_allow_notifications_desc =>
      'Ative para receber notificações push deste grupo.';

  @override
  String get notification_disabled_by_moderator =>
      'As notificações do grupo foram desativadas pelo moderador.';

  @override
  String get notification_enabled_toast => 'Notificações ativadas';

  @override
  String get notification_disabled_toast => 'Notificações desativadas';

  @override
  String get settings_messaging => 'Mensagens';

  @override
  String get settings_everyone_desc =>
      'Todos podem enviar uma mensagem no grupo.';

  @override
  String get settings_only_moderators_desc =>
      'Membros que não são moderadores podem ler mensagens, mas não podem enviar nenhuma mensagem.';

  @override
  String get toast_group_chat_left => 'Você saiu do grupo.';

  @override
  String get toast_group_chat_left_error =>
      'Falha ao sair do grupo. Por favor, tente novamente.';

  @override
  String get toast_group_profile_updated => 'Perfil do grupo atualizado.';

  @override
  String get toast_group_profile_error =>
      'Falha ao atualizar o perfil do grupo. Por favor, tente novamente.';

  @override
  String get toast_group_notification_updated =>
      'Notificações do grupo atualizadas.';

  @override
  String get toast_group_notification_error =>
      'Falha ao atualizar as notificações do grupo. Por favor, tente novamente.';

  @override
  String get toast_member_permissions_updated =>
      'Permissões de membros atualizadas.';

  @override
  String get toast_member_permissions_error =>
      'Falha ao atualizar as permissões de membros. Por favor, tente novamente.';

  @override
  String get toast_member_list_updated => 'Lista de membros atualizada.';

  @override
  String get toast_member_list_error =>
      'Falha ao atualizar a lista de membros. Por favor, tente novamente.';

  @override
  String get toast_banned_users_updated => 'Usuários banidos atualizados.';

  @override
  String get toast_banned_users_error =>
      'Falha ao atualizar usuários banidos. Por favor, tente novamente.';

  @override
  String get toast_members_added => 'Membros adicionados';

  @override
  String get toast_member_added => 'Membro adicionado.';

  @override
  String get toast_members_add_error =>
      'Falha ao adicionar membros. Por favor, tente novamente.';

  @override
  String get toast_member_add_error =>
      'Falha ao adicionar membro. Por favor, tente novamente.';

  @override
  String get toast_member_removed => 'Membro removido.';

  @override
  String get toast_member_remove_error =>
      'Falha ao remover membro. Por favor, tente novamente.';

  @override
  String get toast_member_promoted => 'Membro promovido.';

  @override
  String get toast_member_promote_error =>
      'Falha ao promover membro. Por favor, tente novamente.';

  @override
  String get toast_member_demoted => 'Membro rebaixado.';

  @override
  String get toast_member_demote_error =>
      'Falha ao rebaixar membro. Por favor, tente novamente.';

  @override
  String get toast_user_banned => 'Usuário banido.';

  @override
  String get toast_user_ban_error =>
      'Falha ao banir usuário. Por favor, tente novamente.';

  @override
  String get toast_user_reported => 'Usuário reportado.';

  @override
  String get toast_user_unreported => 'Reporte de usuário removido.';

  @override
  String get toast_user_report_error =>
      'Falha ao reportar/desreportar usuário. Por favor, tente novamente.';

  @override
  String get toast_user_muted => 'Usuário silenciado.';

  @override
  String get toast_user_mute_error =>
      'Falha ao silenciar usuário. Por favor, tente novamente.';

  @override
  String get toast_user_unmuted => 'Usuário dessilenciado.';

  @override
  String get toast_user_unmute_error =>
      'Falha ao dessilenciar usuário. Por favor, tente novamente.';

  @override
  String get user_list_add => 'Adicionar';

  @override
  String get user_list_you => 'Você';

  @override
  String get user_list_you_suffix => ' (Você)';

  @override
  String get chat_new_conversation => 'Nova conversa';

  @override
  String get search_minimum_characters =>
      'Comece sua pesquisa digitando\n pelo menos 3 letras';

  @override
  String get message_sending => 'Enviando...';

  @override
  String get message_not_sent => 'Sua mensagem não foi enviada';

  @override
  String get message_resend => 'Reenviar';

  @override
  String get general_error_title => 'Erro';

  @override
  String get general_error_message => 'Ocorreu um erro';

  @override
  String get chat_message_video_sent => 'Enviou um vídeo';

  @override
  String get chat_message_photo_sent => 'Enviou uma foto';

  @override
  String get chat_message_no_content => 'Sem conteúdo de mensagem';

  @override
  String get chat_archived_label => 'Arquivado';

  @override
  String get chat_add_member => 'Adicionar membro';

  @override
  String get chat_promote_moderator => 'Promover a moderador';

  @override
  String get chat_demote_moderator => 'Rebaixar de moderador';

  @override
  String get chat_mute_user => 'Silenciar usuário';

  @override
  String get chat_unmute_user => 'Desativar silêncio do usuário';

  @override
  String get chat_ban_user => 'Banir usuário';

  @override
  String get chat_unban_user => 'Desbanir usuário';

  @override
  String get chat_remove_member => 'Remover do grupo';

  @override
  String get reaction_tap_to_remove => 'Toque para remover reação';

  @override
  String get image_load_error =>
      'Não foi possível carregar a imagem. Por favor, tente novamente.';
}
