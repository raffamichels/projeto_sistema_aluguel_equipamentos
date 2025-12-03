from flask import Flask, request, jsonify, render_template
import pyodbc
from datetime import datetime, date

app = Flask(__name__)

# --- CONFIGURAÇÃO DE CONEXÃO COM O SQL SERVER ---
connection_string = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=DESKTOP-MNUASRT\\SQLEXPRESS;" 
    "DATABASE=ALUGUEL_EQUIPAMENTOS_DB;"
    "TRUSTED_CONNECTION=yes;"
)

def get_db_connection(autocommit=False):
    """Tenta conectar ao banco de dados."""
    try:
        conn = pyodbc.connect(connection_string, autocommit=autocommit)
        return conn
    except Exception as e:
        print(f"Erro ao conectar ao banco de dados: {e}")
        return None

# --------------------------------------------------------------------------
# FUNÇÕES DE CONSULTA (Backend DQL)
# --------------------------------------------------------------------------

def fetch_data(query, params=None):
    """Executa uma consulta e retorna os resultados como lista de dicionários."""
    conn = get_db_connection()
    if conn is None:
        return None, "Falha na conexão com o banco de dados."
    
    try:
        cursor = conn.cursor()
        cursor.execute(query, params or ())
        
        columns = [column[0] for column in cursor.description]
        results = []
        for row in cursor.fetchall():
            results.append(dict(zip(columns, row)))
            
        return results, None
    except Exception as e:
        return None, f"Erro ao executar consulta: {e}"
    finally:
        conn.close()

# --------------------------------------------------------------------------
# ROTAS DO FLASK
# --------------------------------------------------------------------------

@app.route('/')
def index():
    """Página inicial com menu."""
    return render_template('index.html')

@app.route('/consulta/alugueis_ativos')
def alugueis_ativos():
    """Lista aluguéis em aberto para consulta."""
    query = """
    SELECT 
        A.aluguel_id, 
        C.Nome AS Cliente, 
        A.data_inicio, 
        A.valor_total,
        F.nome AS Funcionario
    FROM ALUGUEL A
    JOIN CLIENTES C ON A.cliente_id = C.cliente_id
    JOIN FUNCIONARIOS F ON A.funcionario_id = F.funcionario_id
    WHERE A.data_devolucao IS NULL;
    """
    data, error = fetch_data(query)
    return render_template('alugueis_ativos.html', alugueis=data, error=error)

@app.route('/consulta/equipamentos_disponiveis')
def equipamentos_disponiveis():
    """Lista equipamentos disponíveis para alugar."""
    query = """
    SELECT 
        E.equipamento_id, 
        E.nome, 
        E.modelo, 
        E.preco_diaria,
        C.nome_categoria
    FROM EQUIPAMENTO E
    JOIN CATEGORIA C ON E.categoria_id = C.categoria_id
    WHERE E.status = 'Disponível';
    """
    data, error = fetch_data(query)
    return render_template('equipamentos_disponiveis.html', equipamentos=data, error=error)

# ROTA PARA FINALIZAR ALUGUEL
@app.route('/operacao/finalizar')
def operacao_finalizar():
    return render_template('operacao_finalizar.html')

@app.route('/api/finalizar_aluguel', methods=['POST'])
def api_finalizar_aluguel():
    """Executa a Stored Procedure SP_FinalizarAluguel."""
    data = request.json
    aluguel_id = data.get('aluguel_id')
    funcionario_id = data.get('funcionario_id')
    data_devolucao_str = data.get('data_devolucao')

    if not aluguel_id or not funcionario_id:
        return jsonify({'success': False, 'message': 'IDs do Aluguel e Funcionário são obrigatórios.'}), 400

    # Converter data se fornecida
    data_devolucao_param = None
    if data_devolucao_str:
        try:
            data_devolucao_param = datetime.strptime(data_devolucao_str, '%Y-%m-%d').date()
        except ValueError:
            return jsonify({'success': False, 'message': 'Formato de data inválido. Use YYYY-MM-DD.'}), 400

    conn = get_db_connection(autocommit=False)
    if conn is None:
        return jsonify({'success': False, 'message': 'Falha na conexão com o banco de dados.'}), 500

    try:
        cursor = conn.cursor()
        
        # Versão que funciona exatamente como no SSMS
        sql = """
        DECLARE @Multa DECIMAL(10,2);
        DECLARE @Msg VARCHAR(500);
        
        EXEC SP_FinalizarAluguel 
            @p_AluguelID = ?,
            @p_DataDevolucao = ?,
            @p_FuncionarioID = ?,
            @p_ValorMulta = @Multa OUTPUT,
            @p_Mensagem = @Msg OUTPUT;
            
        SELECT @Multa AS ValorMulta, @Msg AS Mensagem;
        """
        
        cursor.execute(sql, aluguel_id, data_devolucao_param, funcionario_id)
        
        # Obter o resultado
        row = cursor.fetchone()
        
        if row:
            valor_multa_retornado = row[0] if row[0] is not None else 0.00
            mensagem_retornada = str(row[1]).strip() if row[1] else "Executado sem mensagem"
        else:
            # Tentar buscar de outra forma
            cursor.nextset()
            try:
                row = cursor.fetchone()
                if row:
                    valor_multa_retornado = row[0] if row[0] is not None else 0.00
                    mensagem_retornada = str(row[1]).strip() if row[1] else "Executado sem mensagem"
                else:
                    valor_multa_retornado = 0.00
                    mensagem_retornada = "Executado, mas não retornou mensagem"
            except:
                valor_multa_retornado = 0.00
                mensagem_retornada = "Executado com sucesso"
        
        # Commit da transação
        conn.commit()
        
        return jsonify({
            'success': True,
            'message': mensagem_retornada,
            'valor_multa': f'R$ {float(valor_multa_retornado):.2f}'
        })

    except pyodbc.Error as e:
        conn.rollback()
        error_msg = str(e)
        print(f"Erro pyodbc na SP_FinalizarAluguel: {error_msg}")
        
        # Tratar erro específico da SP
        if 'RAISERROR' in error_msg:
            # Extrair mensagem do RAISERROR
            lines = error_msg.split('\n')
            for line in lines:
                if 'RAISERROR' in line or 'Erro' in line or 'Error' in line:
                    return jsonify({
                        'success': False, 
                        'message': line.strip()
                    }), 500
            
        return jsonify({
            'success': False, 
            'message': f'Erro de banco de dados: {error_msg}'
        }), 500
            
    except Exception as e:
        conn.rollback()
        print(f"Erro geral na SP_FinalizarAluguel: {type(e).__name__} - {str(e)}")
        return jsonify({
            'success': False, 
            'message': f'Erro inesperado: {str(e)}'
        }), 500
    finally:
        conn.close()

# ROTA PARA TESTE DA SP
@app.route('/teste/sp_finalizar', methods=['GET'])
def teste_sp_finalizar():
    """Endpoint para testar a SP diretamente com valores fixos."""
    conn = get_db_connection(autocommit=False)
    
    if conn is None:
        return jsonify({'success': False, 'message': 'Falha na conexão'}), 500
    
    try:
        cursor = conn.cursor()
        
        # Testar com valores fixos (ajuste conforme seu banco)
        cursor.execute("""
        DECLARE @Multa DECIMAL(10,2);
        DECLARE @Msg VARCHAR(500);
        
        EXEC SP_FinalizarAluguel 
            @p_AluguelID = 27,
            @p_DataDevolucao = NULL,
            @p_FuncionarioID = 1,
            @p_ValorMulta = @Multa OUTPUT,
            @p_Mensagem = @Msg OUTPUT;
            
        SELECT @Multa AS Multa, @Msg AS Mensagem;
        """)
        
        row = cursor.fetchone()
        conn.commit()
        
        if row:
            return jsonify({
                'success': True,
                'multa': float(row[0]) if row[0] else 0.00,
                'mensagem': str(row[1]),
                'row_count': cursor.rowcount
            })
        else:
            return jsonify({
                'success': False,
                'message': 'Nenhum resultado retornado'
            })
        
    except Exception as e:
        conn.rollback()
        return jsonify({
            'success': False,
            'error': str(e),
            'type': type(e).__name__
        })
    finally:
        conn.close()

# ROTA PRINCIPAL: REALIZAR ALUGUEL
@app.route('/api/realizar_aluguel', methods=['POST'])
def api_realizar_aluguel():
    """Registra um novo aluguel e seus itens de forma transacional."""
    data = request.json
    cliente_id = data.get('cliente_id')
    funcionario_id = data.get('funcionario_id')
    itens = data.get('itens') # Lista de {id, preco_diaria, quantidade}
    
    if not all([cliente_id, funcionario_id, itens]):
        return jsonify({'success': False, 'message': 'Cliente, Funcionário e Itens são obrigatórios.'}), 400
    
    conn = get_db_connection(autocommit=False) 
    if conn is None:
        return jsonify({'success': False, 'message': 'Falha na conexão com o banco de dados.'}), 500

    try:
        cursor = conn.cursor()
        
        # 1. Calcular Valor Total e Data de Início
        valor_total = sum(item['preco_diaria'] * item['quantidade'] for item in itens)
        data_inicio = date.today().isoformat()
        
        # 2. Inserir na tabela ALUGUEL
        query_aluguel = """
        INSERT INTO ALUGUEL (cliente_id, funcionario_id, data_inicio, valor_total, data_devolucao)
        VALUES (?, ?, ?, ?, NULL);
        SELECT SCOPE_IDENTITY();
        """
        cursor.execute(query_aluguel, cliente_id, funcionario_id, data_inicio, valor_total)
        
        # Obter o ID do novo aluguel
        cursor.nextset()
        novo_aluguel_id = cursor.fetchone()[0]
        
        # Limpar result sets
        while cursor.nextset():
            pass
        
        # 3. Inserir Itens e Atualizar Status
        sql_commands = []
        sql_params = []
        
        for item in itens:
            # Inserir Item (ALUGUEL_ITEM)
            sql_commands.append("""
                INSERT INTO ALUGUEL_ITEM (aluguel_id, equipamento_id, quantidade, valor_diaria)
                VALUES (?, ?, ?, ?);
            """)
            sql_params.extend([novo_aluguel_id, item['id'], item['quantidade'], item['preco_diaria']])
            
            # Atualizar Status do Equipamento
            sql_commands.append("""
                UPDATE EQUIPAMENTO SET status = 'Em Uso' WHERE equipamento_id = ?;
            """)
            sql_params.append(item['id'])
            
            # Atualizar Estoque
            sql_commands.append("""
                UPDATE ESTOQUE 
                SET quant_disponivel = quant_disponivel - ?,
                    data_revisao = CAST(GETDATE() AS DATE)
                WHERE equipamento_id = ?;
            """)
            sql_params.extend([item['quantidade'], item['id']])

        # 4. Executa o bloco inteiro de comandos
        final_sql = "".join(sql_commands)
        cursor.execute(final_sql, *sql_params)
        
        # 5. Adiciona SELECT para garantir resultado
        cursor.execute("SELECT 1 AS Sucesso;")
        
        # Consome result sets
        while cursor.nextset():
            pass
            
        # 6. Commit da transação
        conn.commit()
        
        return jsonify({
            'success': True,
            'message': f'Aluguel ID {int(novo_aluguel_id)} criado com sucesso! Valor total inicial: R$ {valor_total:.2f}. Estoque e Status atualizados.',
            'aluguel_id': int(novo_aluguel_id)
        })

    except Exception as e:
        conn.rollback()
        return jsonify({'success': False, 'message': f'Erro ao registrar aluguel: {type(e).__name__} - {e}'}), 500
    finally:
        conn.close()

# ROTA PARA REGISTRAR MANUTENÇÃO
@app.route('/operacao/manutencao')
def operacao_manutencao():
    fornecedores, _ = fetch_data("SELECT fornecedor_id, nome FROM FORNECEDORES")
    equipamentos_manutencao, _ = fetch_data("SELECT equipamento_id, nome, numero_serie FROM EQUIPAMENTO WHERE status = 'Em Manutenção'")
    return render_template('operacao_manutencao.html', fornecedores=fornecedores, equipamentos_manutencao=equipamentos_manutencao)

@app.route('/api/registrar_manutencao', methods=['POST'])
def api_registrar_manutencao():
    """Registra uma nova manutenção, ativando a TRG_Equipamento_Em_Manutencao."""
    data = request.json
    equipamento_id = data.get('equipamento_id')
    fornecedor_id = data.get('fornecedor_id')
    custo = data.get('custo')
    descricao = data.get('descricao')

    if not all([equipamento_id, fornecedor_id, custo, descricao]):
        return jsonify({'success': False, 'message': 'Todos os campos são obrigatórios para iniciar a manutenção.'}), 400

    conn = get_db_connection(autocommit=True)
    if conn is None:
        return jsonify({'success': False, 'message': 'Falha na conexão com o banco de dados.'}), 500

    try:
        cursor = conn.cursor()
        
        query = """
        INSERT INTO MANUTENCAO (equipamento_id, fornecedor_id, dt_inicio, custo, descricao, dt_final)
        VALUES (?, ?, CAST(GETDATE() AS DATE), ?, ?, NULL)
        """
        cursor.execute(query, equipamento_id, fornecedor_id, custo, descricao)
        
        return jsonify({
            'success': True,
            'message': f'Manutenção registrada com sucesso para o Equipamento ID {equipamento_id}. O status foi alterado automaticamente para "Em Manutenção".'
        })

    except Exception as e:
        return jsonify({'success': False, 'message': f'Erro ao registrar manutenção: {type(e).__name__} - {e}'}), 500
    finally:
        conn.close()

# ROTA PARA LISTAR CLIENTES (útil para selects)
@app.route('/api/clientes', methods=['GET'])
def api_clientes():
    """Retorna lista de clientes para selects."""
    query = "SELECT cliente_id, Nome FROM CLIENTES ORDER BY Nome"
    data, error = fetch_data(query)
    
    if error:
        return jsonify({'success': False, 'message': error}), 500
    
    return jsonify({'success': True, 'clientes': data})

# ROTA PARA LISTAR FUNCIONÁRIOS (útil para selects)
@app.route('/api/funcionarios', methods=['GET'])
def api_funcionarios():
    """Retorna lista de funcionários para selects."""
    query = "SELECT funcionario_id, nome FROM FUNCIONARIOS ORDER BY nome"
    data, error = fetch_data(query)
    
    if error:
        return jsonify({'success': False, 'message': error}), 500
    
    return jsonify({'success': True, 'funcionarios': data})

# ROTA PARA LISTAR EQUIPAMENTOS DISPONÍVEIS (API)
@app.route('/api/equipamentos_disponiveis', methods=['GET'])
def api_equipamentos_disponiveis():
    """Retorna lista de equipamentos disponíveis para aluguel em JSON."""
    query = """
    SELECT 
        E.equipamento_id, 
        E.nome, 
        E.modelo, 
        E.preco_diaria,
        C.nome_categoria,
        ES.quant_disponivel
    FROM EQUIPAMENTO E
    JOIN CATEGORIA C ON E.categoria_id = C.categoria_id
    JOIN ESTOQUE ES ON E.equipamento_id = ES.equipamento_id
    WHERE E.status = 'Disponível' AND ES.quant_disponivel > 0;
    """
    data, error = fetch_data(query)
    
    if error:
        return jsonify({'success': False, 'message': error}), 500
    
    return jsonify({'success': True, 'equipamentos': data})

# ROTA PARA DETALHES DO ALUGUEL ATIVO
@app.route('/api/aluguel/<int:aluguel_id>', methods=['GET'])
def api_aluguel_detalhes(aluguel_id):
    """Retorna detalhes de um aluguel específico."""
    query = """
    SELECT 
        A.aluguel_id, 
        C.Nome AS Cliente, 
        A.data_inicio, 
        A.valor_total,
        F.nome AS Funcionario,
        A.data_devolucao
    FROM ALUGUEL A
    JOIN CLIENTES C ON A.cliente_id = C.cliente_id
    JOIN FUNCIONARIOS F ON A.funcionario_id = F.funcionario_id
    WHERE A.aluguel_id = ?;
    """
    
    data, error = fetch_data(query, (aluguel_id,))
    
    if error:
        return jsonify({'success': False, 'message': error}), 500
    
    if not data:
        return jsonify({'success': False, 'message': 'Aluguel não encontrado'}), 404
    
    # Buscar itens do aluguel
    query_itens = """
    SELECT 
        AI.item_id,
        E.nome AS Equipamento,
        AI.quantidade,
        AI.valor_diaria,
        (AI.quantidade * AI.valor_diaria) AS subtotal
    FROM ALUGUEL_ITEM AI
    JOIN EQUIPAMENTO E ON AI.equipamento_id = E.equipamento_id
    WHERE AI.aluguel_id = ?;
    """
    
    itens, error_itens = fetch_data(query_itens, (aluguel_id,))
    
    return jsonify({
        'success': True, 
        'aluguel': data[0],
        'itens': itens if not error_itens else []
    })

if __name__ == '__main__':
    app.run(debug=True)