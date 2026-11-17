///enigma 2
let 

///enigma 3
/// 
/// estação 1 - indo para Água Clara
/// 
/// bifurcações
let primeira1 = Bifurcacao(1, [Placa(Frente, "Morro Verde "), Placa(Direita, "Cerro Azul")], Direita)

let segunda1 = Bifurcacao(2, [Placa(Esquerda, "Rio Braco"), Placa(Frente, "Bairro Moraes"), Placa(Direita, "Indigo Sul")], Esquerda) 

let terceira1 = Bifurcacao(2, [Placa(Esquerda, "Rodrigo Alves"), Placa(Frente, "Praça Verde"), Placa(Direita, "Bom amigo")], Direita)

let quarta1 = Bifurcacao(2, [Placa(Frente, "Campo Belo"), Placa(Direita, "Água CLara")], Direita)
/// personagens
let jovemPerdido = personagem("Jovem perdido", "[Um homem jovem que, de certa forma, calmo. Ele parece meio perdido sobre onde estamos indo.]", "''Aonde estamos indo? Água Clara? Ah...eu sempre pegava a menor via quando pequeno. Minha mãe me ensinou uma cantiga para eu não me perder nas conexões: 'céu azul, nuvens brancas, grama verde e água clara. É tudo tão lindo que nunca acaba!' ''")

let senhoraPreocupada = personagem("Senhora preocupada", "[Uma mulher idosa com semblante gentil. Ela parece estar preocupa com alguma coisa...]", "''Ai meu Senho, me prometa que vamos sair daqui com segurança! Meus netos...estou tão preocupada com eles! Meus docinhos só pegaram o trem de resgate por Praça Verde horas atrás antes da água tomar tudo por lá...mas mesmo assim meu coração não se aquieta!''")

let jovemDesatenta = personagem("Jovem desatenta", "[Uma mulher jovem e meio confusa sobre a situação atual.]", "''Eu vim da região de Bom Amigo para pegar esse trem e me encontrar com alguns amigos que se refugiaram... Se eu sei de algo? Deixa eu ver... acho que vi algo na TV sobre o Centro Industrial estar suuuper alagado antes de eu vir aqui...ãhn? Ah é, essa regão se passa depois de Água Clara, né...perdão, ainda estou um pouco confusa. Inclusive, a minha região está bem por enquanto!''")

let cachorro = personagem("cachorro", "[Um cachorro está parado em meio a multidão. Ele não parece ter dono. Ele olha para você parecendo querer dizer alguma coisa...]", "''AU AU! AU! AU AU AU! AU AU!''")
///
///estação 2 - indo para Trevo Urbano
/// 
///bifurcações
let primeira2 = Bifurcacao(1, [Placa(Esquerda, "Praça Verde"), Placa(Frente, "Ouro Branco")], Direita)

let segunda2 = Bifurcacao(2, [Placa(Esquerda, "Morro Baixo"), Placa(Frente, "Centro Industrial"), Placa(Direita, "Ouro Branco")], Direita)

let terceira2 = Bifurcacao(3, [Placa(Esquerda, "Porteira Leste"), Placa(Frente, "Ferreira Costa")], Direita)

let quarta2 = Bifurcacao(4, [Placa(Esquerda, "Porteira Leste"), Placa(Frente, "Sitio Baixo"), Placa(Direita, "Cortez Montes")], Direita)

let quinta2 = Bifurcacao(5, [Placa(Esquerda, "Centro Industrial"), Placa(Frente, "Trevo Urbano"), Placa(Direita, "Vila Nova")], Frente)
///personagens 
let senhoraConfusa = personagem("Senhora confusa", "[Uma senhora de boas vestimentas.]", "''Meu filho mora perto da Praça Verde. Ele disse que os trens voltaram a passar normalmente por lá depois de uma interdição! Ele me disse que era para trocar os trilhos. Mas..pensando bem, não me lembro bem se ele estava falando de antes das obras ou não...faz meses que não o vejo.''")

let trabalhadorCansado = personagem("Trabalhador Cansado", "[Um homem com ar de exausto. Ele parece não ter dormido por dias.]", "''Eu estava numa manutenção de trilho numa região aqui perto ontem a noite. Com o tanto de chuva, a gente não conseguiu consertar o fiamento do trilho...isso já  vai fazer semanas. Droga, eu não aaguento mais ter que viajar até lá todo dia...''")

let mulherCalma = personagem("Mulher Calma", "[Uma mulher com um semblante calmo, apesar da situação.]", "''Hm, eu não sei nada sobre ferrovias. Na verdade, só comecei a andar recentemente de trem, antes de todo esse desastre de chuvas e alagamento por dias, é claro. Só fui descobrir que eu podia entrar no Centro Industrial pela Poteira Leste há pouco tempo atrás! Eu teria poupado um pouco mais de tempo se eu soubesse disso antes...bom, as duas estações são grudadas uma na outra, então não tenho certeza...''")

let senhorObservador = personagem("Senhor Observador", "[um homem idoso com uma ótima intuição...pelo menos é isso que ele dá a entender.]", "''Passei pelo Morro Baixo hoje cedo e vi gente pela Estação! Todos estavam bem disposstos, mas não pareciam esperar nenhum trem...também tinha algumas máquinas e caminhões, uma baita comossão...ninguém podia chegar perto de lá.''")

let homemInformado = personagem("Homem Informado", "[Um homem que parece um estudioso e muito bem informado.]", "Você ouviu falar que o terreno próximo à Vila Nova vêm tendo movimentações no solo? Não houve desmoronamento completo, mas há risco de acontecer. Aquela região é extremamente sensível à infiltração de água.''")

let homemConfuso = personagem("Homem Confuso", "[Um homem meio assustado pelo desastre. Parece que ele já se locomoveu bastante pela região antes de vir aqui.]", "''Eu estava indo para Cortez Montes, mas me mandaram esperar. Depois, um funcionário disse que a linha estava funcionando. Não sei se era a linha de ida ou de volta. Só sei que vi o trem seguindo pela direita dele.''")

///personagem de prioridade - o jogador não pode interagir com ninguém antes dele
let maeExausta = personagem("Mãe Exausta", "[Uma mulher tentando acalmar seu-]", "''BUAAAAAH! BUAAAAAH!!!! BUAAAAH!'' ''Ai céus...me perdoe! Não estou conseguindo acalmar meu bebê...essa situação está bem estressante para nós, me perdõe!")

///estação 3 - indo para Estação Acará
/// 
///bifurcações
let primeira3 = Bifurcacao(1, [Placa(Esquerda, "Palmeiras"), Placa(Frente, "Aurora"), Placa(Direita, "Esperanca")], Frente)

let segunda3 = Bifurcacao(2, [Placa(Frente, "Horizonte"), Placa(Direita, "São Miguel")], Frente)

let terceira3 = Bifurcacao(3, [Placa(Esquerda, "Estação Central"), Placa(Frente, "Parque das águas"), Placa(Direita, "Vila Industrial")], Esquerda)

let quarta3 = Bifurcacao(4, [Placa(Frente, "Estação Flores"), Placa(Direita, "Novo Horizonte")], Frente)

let quinta3 = Bifurcacao(5, [Placa(Esquerda, "Acará"), Placa(Frente, "São Bento"), Placa(Direita, "Estação Industrial")], Esquerda)

///personagens
let mulherTensa = personagem("Mulher Tensa", "[Uma mulher um pouco tensa. Segurando seu braço tem uma garotinha que se esconde de você por timidez]", "''Sabe, minha filha estuda perto da Vila Esperança. A escola mandou todo mundo embora mais cedo, mas ela disse que os funcionários estavam preocupados mesmo era com a avenida que passa atrás do prédio. Sempre que chove muito, aquela parte fica cheia de água. Dessa vez, parece que nem deu tempo de esperar a chuva passar.''")

let trabalhadorFerroviario = personagem("Trabalhador ferroviário", "[Um homem de baixa estatura. Ele parece ter trago bastante equipamento com ele.]", "''Eu fazia manutenção perto da Estação São Miguel. Tinha um pessoal trabalhando por lá quando começou a chover forte. Um colega comentou que os trilhos daquele trecho já estavam apresentando problemas. O pior é que a água começou a subir muito rápido, e ninguém conseguiu terminar o serviço. Vou ver se alguma estação por perto precisa de alguma ajuda a mais.''")

let senhorSorridente = personagem("Senhor Sorridente", "[Um homem idoso com uma expressão serena e amável.]", "''Meu irmão mora perto do Jardim das Palmeiras. Ele sempre pega aquele trem que passa pela linha da esquerda, mas hoje me ligou dizendo que precisou sair de casa às pressas. A água já tinha passado da altura do portão. Pelo que ele falou, a rua de acesso à estação também estava ficando complicada.''")

let estudanteUniversitaria = personagem("Estudante Universitária", "[Uma jovem estudante universitária.]", "''Meu namorado mora perto do Parque das Águas. Ele me mandou uma mensagem dizendo que conseguiu sair antes de a ponte ficar interditada. A mãe dele ficou para trás porque não queria abandonar a casa. Ele disse que estava tentando chegar à estação, mas não sabia se ainda dava para passar por lá.''")

let adolescente = personagem("Estudante Adolescente", "[Um adolescente meio afobado, acompanhado pelos pais.]", "''Hmm, acho que ontem ouvi de um amigo que o nível da água ia aumentar perigosamente em Horizonte...ou era NOVA Horizonte? Não lembro qual delas...Ah! E antes de eu vir aqui, eu estava trocando mensagens com minha amiga que mora perto da Vila Industrial. Ela disse que logo logo teria que evacuar porque os níveis mais baixos já foram alagados por aquela região. Mas ela está bem, ainda bem!''")

let passageiroAtento = personagem("Passageiro Atento", "[Um jovem atento aos arredores. Parece que ele se preparou bem antes de vir para cá.]", "''Ainda bem que ouvi os alertas ontem e já arrumei todas as minhas coisas! Me mudei recentemente da Estação industrial, por isso muitas das minhas coisas estavam fáceis de pegar quando evacuei. Foi tão difícil mudar minhas coisas, aquela região é muito baixa, aí as estradas eram muito esquisitas...espero que a enchente não destrua elas...''")

///mini evento - juntar família
let maeDesesperada = personagem("Mãe Desesperada", "[Ela parece estar procrando por alguém.]", "''Olá condutor...por acaso você viu o meu filho? Eu embarquei com ele mas conforme a movimetno aqui aumentava, acabei perdendo ele de vista! Não estou achando ele e não sei mais o que fazer. Poderia me ajudar a encontrar ele, por favor???''")

///esse aqui vai ser recolhido
let criancaRecolhivel = personagem("Criança perdida", "[Um garotinho choroso]", "")


/// enigma 1 -> o condutor deve consertar as coisas pela sala de condutor
