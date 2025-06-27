import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late Supabase supabase;

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://xzbwoadxwadwvvoclbtr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6YndvYWR4d2Fkd3Z2b2NsYnRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2OTE0ODQsImV4cCI6MjA2NDI2NzQ4NH0.tIDWFxZDyBf2Y2f4P4N_KcvQ5WzYz34wr0BsGrLYeO4',
  );
  supabase = Supabase.instance;
  runApp(MaterialApp(home: MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<StatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Widget pagina = const Center(child: CircularProgressIndicator(color: Colors.amber));
  List<Map<String, dynamic>> dados = [];
  TextEditingController txtProduto = TextEditingController();
  TextEditingController txtDescricao = TextEditingController();

  int? idEditando;

  void limparCampos() {
    txtProduto.clear();
    txtDescricao.clear();
    idEditando = null;
  }

  void exclui(var id) {
    supabase.client.from('Estoque').delete().eq('id', id).then((x) {
      getDados();
    });
  }

  void atualizar() {
    if (idEditando != null) {
      supabase.client
          .from("Estoque")
          .update({'produto': txtProduto.text, 'descricao': txtDescricao.text})
          .eq('id', idEditando!)
          .then((v) {
        setState(() {
          limparCampos();
          getDados();
        });
      });
    }
  }

  void getDados() {
    setState(() {
      pagina = const Center(child: CircularProgressIndicator(color: Colors.amber));
    });
    supabase.client.from('Estoque').select().then((v) {
      dados = List<Map<String, dynamic>>.from(v);
      setState(() {
        pagina = ListView.builder(
          itemCount: dados.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(dados[index]['produto'] ?? ''),
              subtitle: Text(dados[index]['descricao'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        idEditando = dados[index]['id'];
                        txtProduto.text = dados[index]['produto'];
                        txtDescricao.text = dados[index]['descricao'];
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => exclui(dados[index]['id']),
                  ),
                ],
              ),
            );
          },
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getDados();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("SUPABASE 01"),
          backgroundColor: const Color.fromARGB(255, 0, 255, 0),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      controller: txtProduto,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "produto",
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: txtDescricao,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "descricao",
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        supabase.client
                            .from("Estoque")
                            .insert({
                              'produto': txtProduto.text,
                              'descricao': txtDescricao.text,
                            })
                            .then((v) {
                              limparCampos();
                              getDados();
                            });
                      },
                      child: const Text("Salvar"),
                    ),
                    if (idEditando != null)
                      TextButton(
                        onPressed: atualizar,
                        child: const Text("Atualizar"),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                color: const Color.fromARGB(255, 54, 174, 244),
                padding: const EdgeInsets.all(10),
                child: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.all(10),
                  child: pagina,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
