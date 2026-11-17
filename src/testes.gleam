import sgleam/check

pub fn jogador_examples() {
  let player =
    Jogador(nome: "Pedro", local: "Estacao Central", inventario: [], pistas: [])

  //
  // Teste de adicionar e remover objeto
  let player_com_obj = adicionar_obj(player, "Pe de cabra")
  let player_sem_obj = gastar_obj(player_com_obj, "Pe de cabra")
  check.eq(player_com_obj.inventario, ["Pe de cabra"])
  check.eq(possui_obj(player_com_obj, "Pe de cabra"), True)
  check.eq(player_sem_obj.inventario, [])

  // Teste de adicionar pista
  let player_com_pista = adicionar_pista(player, "A chave esta na secretaria.")
  check.eq(player_com_pista.pistas, ["A chave esta na secretaria."])
  check.eq(possui_pista(player_com_pista, "A chave esta na secretaria."), True)

  // Teste de evitar pistas duplicadas
  let player_pista_repetida =
    adicionar_pista(player_com_pista, "A chave esta na secretaria.")
  check.eq(player_pista_repetida.pistas, ["A chave esta na secretaria."])

  // Teste de deslocamento
  let player_movido = mudar_local(player, "Cabine")
  check.eq(player_movido.local, "Cabine")

  let player = reset_progresso(player_com_obj)
  check.eq(player.inventario, [])
  check.eq(player.pistas, [])
}

//
//
//
pub fn objeto_examples() {
  let player =
    Jogador(nome: "Pedro", local: "Secretaria", inventario: [], pistas: [])
  let chave_de_fenda =
    Objeto(
      nome: "Chave de Fenda",
      descricao: "Uma ferramenta de conserto.",
      interacao: acao_coletar("Chave de fenda"),
      estado: Coletavel,
    )
  let fax =
    Objeto(
      nome: "Fax",
      descricao: "Um aparelho quebrado sobre a mesa.",
      interacao: fn(player) { player },
      estado: Quebrado("Chave de fenda", Disponivel),
    )
  let mensagem =
    Objeto(
      nome: "Mensagem do fax",
      descricao: "Um documento impresso pelo fax.",
      interacao: acao_ler_mensagem("Verifique o armario da plataforma."),
      estado: Disponivel,
    )

  //
  // Teste de interacao com objeto (pegar)
  let player_apos_coleta = interagir(chave_de_fenda, player)
  check.eq(player_apos_coleta.inventario, ["Chave de fenda"])

  // Teste de interacao com objeto (consertar)
  let fax_consertado = consertar(fax, player_apos_coleta)
  check.eq(fax_consertado.estado, Disponivel)
  let fax_ainda_quebrado = consertar(fax, player)
  check.eq(fax_ainda_quebrado.estado, Quebrado("Chave de fenda", Disponivel))

  // Teste de interacao com objeto (ler mensagem)
  let player_apos_leitura = interagir(mensagem, player)
  check.eq(player_apos_leitura.pistas, ["Verifique o armario da plataforma."])
}

///
/// 
/// 
pub fn ambiente_examples() {
  let pe_de_cabra =
    Objeto(
      nome: "Pe de cabra",
      descricao: "Uma ferramenta.",
      interacao: acao_coletar("Pe de cabra"),
      estado: Coletavel,
    )

  let ambiente =
    Ambiente(
      nome: "Plataforma",
      descricao: "Uma plataforma alagada.",
      objetos: [pe_de_cabra],
      saidas: ["Secretaria"],
      acessivel: True,
    )

  check.eq(string.contains(explorar_ambiente(ambiente), "Plataforma"), True)
  check.eq(buscar_objeto(ambiente, "Pe de cabra"), Ok(pe_de_cabra))
  check.eq(buscar_objeto(ambiente, "Chave"), Error(Nil))
  check.eq(inverter_acessibilidade(ambiente).acessivel, False)
}
