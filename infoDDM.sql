--
-- PostgreSQL database dump
--



-- Configurações de sessão para restauração consistente

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 16462)
-- Name: administrador; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA administrador;


--
-- TOC entry 8 (class 2615 OID 17010)
-- Name: atendimento; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA atendimento;


--
-- TOC entry 9 (class 2615 OID 41612)
-- Name: auditoria; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auditoria;


--
-- TOC entry 7 (class 2615 OID 16919)
-- Name: triagem; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA triagem;


--
-- TOC entry 275 (class 1255 OID 49805)
-- Name: func_auditar_alteracoes(); Type: FUNCTION; Schema: auditoria; Owner: -
--

CREATE FUNCTION auditoria.func_auditar_alteracoes() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_id_column TEXT;
    v_id_value TEXT;
BEGIN
    
	-- Determina o nome da coluna ID baseado no nome da tabela
    v_id_column := 'id_' || LOWER(TG_TABLE_NAME);


    -- Verifica o tipo de operação (INSERT, UPDATE, DELETE)
    IF (TG_OP = 'DELETE') THEN
		EXECUTE format('SELECT ($1).%I::text', v_id_column) USING OLD INTO v_id_value;

        INSERT INTO auditoria.log_auditoria (
            tabela_afetada, esquema_afetado, id_registro_afetado,
            tipo_operacao, dados_anteriores, id_usuario_responsavel
        ) VALUES (
            TG_TABLE_NAME, TG_TABLE_SCHEMA, v_id_value,
            'D', to_jsonb(OLD), current_setting('app.current_user_id', true)::integer
        );
        RETURN OLD;
    
    ELSIF (TG_OP = 'UPDATE') THEN
		EXECUTE format('SELECT ($1).%I::text', v_id_column) USING NEW INTO v_id_value;

        INSERT INTO auditoria.log_auditoria (
            tabela_afetada, esquema_afetado, id_registro_afetado,
            tipo_operacao, dados_anteriores, dados_novos, id_usuario_responsavel
        ) VALUES (
            TG_TABLE_NAME, TG_TABLE_SCHEMA, v_id_value,
            'U', to_jsonb(OLD), to_jsonb(NEW), current_setting('app.current_user_id', true)::integer
        );
        RETURN NEW;
    
    ELSIF (TG_OP = 'INSERT') THEN
		EXECUTE format('SELECT ($1).%I::text', v_id_column) USING NEW INTO v_id_value;

        INSERT INTO auditoria.log_auditoria (
            tabela_afetada, esquema_afetado, id_registro_afetado,
            tipo_operacao, dados_novos, id_usuario_responsavel
        ) VALUES (
            TG_TABLE_NAME, TG_TABLE_SCHEMA, v_id_value,
            'I', to_jsonb(NEW), current_setting('app.current_user_id', true)::integer
        );
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 237 (class 1259 OID 25251)
-- Name: enfermagem; Type: TABLE; Schema: administrador; Owner: -
--

CREATE TABLE administrador.enfermagem (
    id_enfermagem integer NOT NULL,
    coren character varying NOT NULL,
    id_voluntario_fk integer NOT NULL
);


--
-- TOC entry 236 (class 1259 OID 25250)
-- Name: enfermagem_id_enfermagem_seq; Type: SEQUENCE; Schema: administrador; Owner: -
--

CREATE SEQUENCE administrador.enfermagem_id_enfermagem_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3706 (class 0 OID 0)
-- Dependencies: 236
-- Name: enfermagem_id_enfermagem_seq; Type: SEQUENCE OWNED BY; Schema: administrador; Owner: -
--

ALTER SEQUENCE administrador.enfermagem_id_enfermagem_seq OWNED BY administrador.enfermagem.id_enfermagem;


--
-- TOC entry 241 (class 1259 OID 25279)
-- Name: especialidade_medica; Type: TABLE; Schema: administrador; Owner: -
--

CREATE TABLE administrador.especialidade_medica (
    id_especialidade_medica integer NOT NULL,
    rqe character varying NOT NULL,
    id_medicina_fk integer NOT NULL
);


--
-- TOC entry 240 (class 1259 OID 25278)
-- Name: especialidade_medica_id_especialidade_seq; Type: SEQUENCE; Schema: administrador; Owner: -
--

CREATE SEQUENCE administrador.especialidade_medica_id_especialidade_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3707 (class 0 OID 0)
-- Dependencies: 240
-- Name: especialidade_medica_id_especialidade_seq; Type: SEQUENCE OWNED BY; Schema: administrador; Owner: -
--

ALTER SEQUENCE administrador.especialidade_medica_id_especialidade_seq OWNED BY administrador.especialidade_medica.id_especialidade_medica;


--
-- TOC entry 227 (class 1259 OID 16536)
-- Name: exames; Type: TABLE; Schema: administrador; Owner: -
--

CREATE TABLE administrador.exames (
    id_exames integer NOT NULL,
    nome character varying,
    descricao character varying,
    quantidade integer NOT NULL,
    status integer,
    id_expedicao_fk integer NOT NULL
);


--
-- TOC entry 226 (class 1259 OID 16535)
-- Name: exames_id_exame_seq; Type: SEQUENCE; Schema: administrador; Owner: -
--

CREATE SEQUENCE administrador.exames_id_exame_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3708 (class 0 OID 0)
-- Dependencies: 226
-- Name: exames_id_exame_seq; Type: SEQUENCE OWNED BY; Schema: administrador; Owner: -
--

ALTER SEQUENCE administrador.exames_id_exame_seq OWNED BY administrador.exames.id_exames;


--
-- TOC entry 223 (class 1259 OID 16494)
-- Name: expedicao; Type: TABLE; Schema: administrador; Owner: -
--

CREATE TABLE administrador.expedicao (
    id_expedicao integer NOT NULL,
    local character varying,
    inicio date NOT NULL,
    fim date,
    status character varying(20),
    nome character varying,
    CONSTRAINT chk_status CHECK (((status)::text = ANY ((ARRAY['planejada'::character varying, 'em_andamento'::character varying, 'concluida'::character varying, 'cancelada'::character varying])::text[])))
);


--
-- TOC entry 222 (class 1259 OID 16492)
-- Name: expedicao_id_expedicao_seq; Type: SEQUENCE; Schema: administrador; Owner: -
--

CREATE SEQUENCE administrador.expedicao_id_expedicao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3709 (class 0 OID 0)
-- Dependencies: 222
-- Name: expedicao_id_expedicao_seq; Type: SEQUENCE OWNED BY; Schema: administrador; Owner: -
--

ALTER SEQUENCE administrador.expedicao_id_expedicao_seq OWNED BY administrador.expedicao.id_expedicao;


--
-- TOC entry 225 (class 1259 OID 16509)
-- Name: insumos; Type: TABLE; Schema: administrador; Owner: -
--

CREATE TABLE administrador.insumos (
    id_insumos integer NOT NULL,
    lote character varying,
    quantidade integer NOT NULL,
    id_expedicao_fk integer NOT NULL
);


--
-- TOC entry 224 (class 1259 OID 16508)
-- Name: insumos_id_insumos_seq; Type: SEQUENCE; Schema: administrador; Owner: -
--

CREATE SEQUENCE administrador.insumos_id_insumos_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3710 (class 0 OID 0)
-- Dependencies: 224
-- Name: insumos_id_insumos_seq; Type: SEQUENCE OWNED BY; Schema: administrador; Owner: -
--

ALTER SEQUENCE administrador.insumos_id_insumos_seq OWNED BY administrador.insumos.id_insumos;


--
-- TOC entry 232 (class 1259 OID 25215)
-- Name: medicina; Type: TABLE; Schema: administrador; Owner: -
--

CREATE TABLE administrador.medicina (
    id_voluntario_fk integer NOT NULL,
    id_medicina integer NOT NULL,
    crm character varying NOT NULL
);


--
-- TOC entry 233 (class 1259 OID 25227)
-- Name: medico_id_medico_seq; Type: SEQUENCE; Schema: administrador; Owner: -
--

CREATE SEQUENCE administrador.medico_id_medico_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3711 (class 0 OID 0)
-- Dependencies: 233
-- Name: medico_id_medico_seq; Type: SEQUENCE OWNED BY; Schema: administrador; Owner: -
--

ALTER SEQUENCE administrador.medico_id_medico_seq OWNED BY administrador.medicina.id_medicina;


--
-- TOC entry 239 (class 1259 OID 25265)
-- Name: odontologia; Type: TABLE; Schema: administrador; Owner: -
--

CREATE TABLE administrador.odontologia (
    id_odontologia integer NOT NULL,
    cro character varying NOT NULL,
    id_voluntario_fk integer NOT NULL
);


--
-- TOC entry 238 (class 1259 OID 25264)
-- Name: odontologia_id_odonto_seq; Type: SEQUENCE; Schema: administrador; Owner: -
--

CREATE SEQUENCE administrador.odontologia_id_odonto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3712 (class 0 OID 0)
-- Dependencies: 238
-- Name: odontologia_id_odonto_seq; Type: SEQUENCE OWNED BY; Schema: administrador; Owner: -
--

ALTER SEQUENCE administrador.odontologia_id_odonto_seq OWNED BY administrador.odontologia.id_odontologia;


--
-- TOC entry 229 (class 1259 OID 16898)
-- Name: procedimentos; Type: TABLE; Schema: administrador; Owner: -
--

CREATE TABLE administrador.procedimentos (
    id_procedimentos integer NOT NULL,
    nome character varying NOT NULL,
    descricao text,
    id_expedicao_fk integer NOT NULL
);


--
-- TOC entry 228 (class 1259 OID 16897)
-- Name: precedimentos_id_procedimento_seq; Type: SEQUENCE; Schema: administrador; Owner: -
--

CREATE SEQUENCE administrador.precedimentos_id_procedimento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3713 (class 0 OID 0)
-- Dependencies: 228
-- Name: precedimentos_id_procedimento_seq; Type: SEQUENCE OWNED BY; Schema: administrador; Owner: -
--

ALTER SEQUENCE administrador.precedimentos_id_procedimento_seq OWNED BY administrador.procedimentos.id_procedimentos;


--
-- TOC entry 235 (class 1259 OID 25237)
-- Name: psicologia; Type: TABLE; Schema: administrador; Owner: -
--

CREATE TABLE administrador.psicologia (
    id_psicologia integer NOT NULL,
    crp character varying NOT NULL,
    id_voluntario_fk integer NOT NULL
);


--
-- TOC entry 234 (class 1259 OID 25236)
-- Name: psicologa_id_psicologa_seq; Type: SEQUENCE; Schema: administrador; Owner: -
--

CREATE SEQUENCE administrador.psicologa_id_psicologa_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3714 (class 0 OID 0)
-- Dependencies: 234
-- Name: psicologa_id_psicologa_seq; Type: SEQUENCE OWNED BY; Schema: administrador; Owner: -
--

ALTER SEQUENCE administrador.psicologa_id_psicologa_seq OWNED BY administrador.psicologia.id_psicologia;


--
-- TOC entry 220 (class 1259 OID 16463)
-- Name: usuarios; Type: TABLE; Schema: administrador; Owner: -
--

-- Opção B: Adicionar comentário explicativo
COMMENT ON COLUMN administrador.usuarios.senha IS
'DEVE conter hash de senha (ex: bcrypt), NUNCA senha em texto puro';

CREATE TABLE administrador.usuarios (
    nivel integer NOT NULL,
    "user" character varying NOT NULL,
    senha character varying NOT NULL,
    email character varying NOT NULL,
    id_usuarios integer NOT NULL
);


--
-- TOC entry 3715 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN usuarios."user"; Type: COMMENT; Schema: administrador; Owner: -
--

COMMENT ON COLUMN administrador.usuarios."user" IS 'User para logar no sistema.';


--
-- TOC entry 258 (class 1259 OID 66532)
-- Name: usuarios_id_usuarios_seq; Type: SEQUENCE; Schema: administrador; Owner: -
--

CREATE SEQUENCE administrador.usuarios_id_usuarios_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3716 (class 0 OID 0)
-- Dependencies: 258
-- Name: usuarios_id_usuarios_seq; Type: SEQUENCE OWNED BY; Schema: administrador; Owner: -
--

ALTER SEQUENCE administrador.usuarios_id_usuarios_seq OWNED BY administrador.usuarios.id_usuarios;


--
-- TOC entry 260 (class 1259 OID 66675)
-- Name: vinculo_expedicao_voluntario; Type: TABLE; Schema: administrador; Owner: -
--

CREATE TABLE administrador.vinculo_expedicao_voluntario (
    id_expedicao_fk integer NOT NULL,
    id_voluntario_fk integer NOT NULL,
    id_vinculo_expedicao_voluntario integer NOT NULL
);


--
-- TOC entry 261 (class 1259 OID 66688)
-- Name: vinculo_expedicao_voluntario_id_vinculo_expedicao_voluntari_seq; Type: SEQUENCE; Schema: administrador; Owner: -
--

CREATE SEQUENCE administrador.vinculo_expedicao_voluntario_id_vinculo_expedicao_voluntari_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3717 (class 0 OID 0)
-- Dependencies: 261
-- Name: vinculo_expedicao_voluntario_id_vinculo_expedicao_voluntari_seq; Type: SEQUENCE OWNED BY; Schema: administrador; Owner: -
--

ALTER SEQUENCE administrador.vinculo_expedicao_voluntario_id_vinculo_expedicao_voluntari_seq OWNED BY administrador.vinculo_expedicao_voluntario.id_vinculo_expedicao_voluntario;


--
-- TOC entry 221 (class 1259 OID 16471)
-- Name: voluntarios; Type: TABLE; Schema: administrador; Owner: -
--

CREATE TABLE administrador.voluntarios (
    nome character varying NOT NULL,
    cargo character varying NOT NULL,
    cpf character varying,
    id_login_fk integer NOT NULL,
    id_voluntario integer NOT NULL
);


--
-- TOC entry 259 (class 1259 OID 66541)
-- Name: voluntarios_id_voluntario_seq; Type: SEQUENCE; Schema: administrador; Owner: -
--

CREATE SEQUENCE administrador.voluntarios_id_voluntario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3718 (class 0 OID 0)
-- Dependencies: 259
-- Name: voluntarios_id_voluntario_seq; Type: SEQUENCE OWNED BY; Schema: administrador; Owner: -
--

ALTER SEQUENCE administrador.voluntarios_id_voluntario_seq OWNED BY administrador.voluntarios.id_voluntario;


--
-- TOC entry 242 (class 1259 OID 33395)
-- Name: fila_consulta_medica; Type: TABLE; Schema: atendimento; Owner: -
--

CREATE TABLE atendimento.fila_consulta_medica (
    status character varying NOT NULL,
    id_medica_fk integer,
    id_fila_consulta_medica integer NOT NULL,
    id_ficha_fk integer NOT NULL
);


--
-- TOC entry 257 (class 1259 OID 66488)
-- Name: fila_consulta_medica_id_ficha_fk_seq; Type: SEQUENCE; Schema: atendimento; Owner: -
--

CREATE SEQUENCE atendimento.fila_consulta_medica_id_ficha_fk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3719 (class 0 OID 0)
-- Dependencies: 257
-- Name: fila_consulta_medica_id_ficha_fk_seq; Type: SEQUENCE OWNED BY; Schema: atendimento; Owner: -
--

ALTER SEQUENCE atendimento.fila_consulta_medica_id_ficha_fk_seq OWNED BY atendimento.fila_consulta_medica.id_ficha_fk;


--
-- TOC entry 243 (class 1259 OID 41592)
-- Name: fila_consulta_medica_id_fila_consulta_medica_seq; Type: SEQUENCE; Schema: atendimento; Owner: -
--

CREATE SEQUENCE atendimento.fila_consulta_medica_id_fila_consulta_medica_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3720 (class 0 OID 0)
-- Dependencies: 243
-- Name: fila_consulta_medica_id_fila_consulta_medica_seq; Type: SEQUENCE OWNED BY; Schema: atendimento; Owner: -
--

ALTER SEQUENCE atendimento.fila_consulta_medica_id_fila_consulta_medica_seq OWNED BY atendimento.fila_consulta_medica.id_fila_consulta_medica;


--
-- TOC entry 247 (class 1259 OID 49827)
-- Name: consentimentos; Type: TABLE; Schema: auditoria; Owner: -
--

CREATE TABLE auditoria.consentimentos (
    id_consentimentos integer NOT NULL,
    versao_termo character varying(50) NOT NULL,
    tipo_consentimento character varying(100) NOT NULL,
    dados_consentidos jsonb NOT NULL,
    data_hora_consentimento timestamp with time zone NOT NULL,
    meio_captura character varying(50) NOT NULL,
    ip_captura character varying(50),
    data_hora_revogacao timestamp with time zone,
    motivo_revogacao text,
    id_paciente_fk integer NOT NULL
);


--
-- TOC entry 3721 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE consentimentos; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON TABLE auditoria.consentimentos IS 'Gestão de Consentimentos
-- capturar, armazenar e gerenciar consentimentos

Obrigatoriedade: Artigos 7º e 8º da LGPD';


--
-- TOC entry 3722 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN consentimentos.dados_consentidos; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON COLUMN auditoria.consentimentos.dados_consentidos IS '-- Campos específicos consentidos';


--
-- TOC entry 3723 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN consentimentos.meio_captura; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON COLUMN auditoria.consentimentos.meio_captura IS '-- ''site'', ''app'', ''formulario''';


--
-- TOC entry 246 (class 1259 OID 49826)
-- Name: consentimentos_id_consentimentos_seq; Type: SEQUENCE; Schema: auditoria; Owner: -
--

CREATE SEQUENCE auditoria.consentimentos_id_consentimentos_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3724 (class 0 OID 0)
-- Dependencies: 246
-- Name: consentimentos_id_consentimentos_seq; Type: SEQUENCE OWNED BY; Schema: auditoria; Owner: -
--

ALTER SEQUENCE auditoria.consentimentos_id_consentimentos_seq OWNED BY auditoria.consentimentos.id_consentimentos;


--
-- TOC entry 254 (class 1259 OID 49884)
-- Name: fluxo_tabelas; Type: TABLE; Schema: auditoria; Owner: -
--

CREATE TABLE auditoria.fluxo_tabelas (
    id_fluxo_tabela integer NOT NULL,
    fluxo_tratamento_fk integer NOT NULL,
    nome_tabela character varying(100) NOT NULL,
    operacoes character varying(1) NOT NULL,
    responsavel character varying(50) NOT NULL
);


--
-- TOC entry 3725 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN fluxo_tabelas.operacoes; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON COLUMN auditoria.fluxo_tabelas.operacoes IS 'I (insert), D (Delete), U (UPDATE).';


--
-- TOC entry 253 (class 1259 OID 49883)
-- Name: fluxo_tabelas_id_fluxo_tabela_seq; Type: SEQUENCE; Schema: auditoria; Owner: -
--

CREATE SEQUENCE auditoria.fluxo_tabelas_id_fluxo_tabela_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3726 (class 0 OID 0)
-- Dependencies: 253
-- Name: fluxo_tabelas_id_fluxo_tabela_seq; Type: SEQUENCE OWNED BY; Schema: auditoria; Owner: -
--

ALTER SEQUENCE auditoria.fluxo_tabelas_id_fluxo_tabela_seq OWNED BY auditoria.fluxo_tabelas.id_fluxo_tabela;


--
-- TOC entry 252 (class 1259 OID 49873)
-- Name: fluxo_tratamento; Type: TABLE; Schema: auditoria; Owner: -
--

CREATE TABLE auditoria.fluxo_tratamento (
    id_fluxo_tratamento integer NOT NULL,
    nome_fluxo character varying(100) NOT NULL,
    descricao text NOT NULL,
    origem_dados character varying(100),
    categoria_dados text NOT NULL,
    finalidade_primaria text NOT NULL,
    finalidade_secundaria text,
    base_legal character varying(100) NOT NULL,
    responsavel character varying(100) NOT NULL,
    registro_impacto boolean DEFAULT false NOT NULL
);


--
-- TOC entry 3727 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN fluxo_tratamento.registro_impacto; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON COLUMN auditoria.fluxo_tratamento.registro_impacto IS 'Necessita de Relatório de Impacto à Proteção de Dados?';


--
-- TOC entry 251 (class 1259 OID 49872)
-- Name: fluxo_tratamento_id_fluxo_tratamento_seq; Type: SEQUENCE; Schema: auditoria; Owner: -
--

CREATE SEQUENCE auditoria.fluxo_tratamento_id_fluxo_tratamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3728 (class 0 OID 0)
-- Dependencies: 251
-- Name: fluxo_tratamento_id_fluxo_tratamento_seq; Type: SEQUENCE OWNED BY; Schema: auditoria; Owner: -
--

ALTER SEQUENCE auditoria.fluxo_tratamento_id_fluxo_tratamento_seq OWNED BY auditoria.fluxo_tratamento.id_fluxo_tratamento;


--
-- TOC entry 245 (class 1259 OID 41614)
-- Name: log_auditoria; Type: TABLE; Schema: auditoria; Owner: -
--

CREATE TABLE auditoria.log_auditoria (
    id_log bigint NOT NULL,
    tabela_afetada character varying(100) NOT NULL,
    esquema_afetado character varying(50) NOT NULL,
    id_registro_afetado character varying(100),
    tipo_operacao character(1) NOT NULL,
    dados_anteriores jsonb,
    dados_novos jsonb,
    id_usuario_responsavel integer,
    ip_conexao character varying(45),
    data_hora_operacao timestamp with time zone DEFAULT now()
);


--
-- TOC entry 244 (class 1259 OID 41613)
-- Name: log_auditoria_id_log_seq; Type: SEQUENCE; Schema: auditoria; Owner: -
--

CREATE SEQUENCE auditoria.log_auditoria_id_log_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3729 (class 0 OID 0)
-- Dependencies: 244
-- Name: log_auditoria_id_log_seq; Type: SEQUENCE OWNED BY; Schema: auditoria; Owner: -
--

ALTER SEQUENCE auditoria.log_auditoria_id_log_seq OWNED BY auditoria.log_auditoria.id_log;


--
-- TOC entry 250 (class 1259 OID 49862)
-- Name: mapeamento_dados; Type: TABLE; Schema: auditoria; Owner: -
--

CREATE TABLE auditoria.mapeamento_dados (
    id_mapeamento_dados integer NOT NULL,
    tabela character varying(100) NOT NULL,
    campo character varying(100) NOT NULL,
    categoria character varying(50) NOT NULL,
    tipo_dado character varying(100) NOT NULL,
    finalidade text NOT NULL,
    base_legal character varying(50) NOT NULL,
    prazo_retencao character varying(50) NOT NULL,
    compartilhado boolean DEFAULT false,
    destino_compartilhamento text
);


--
-- TOC entry 3730 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE mapeamento_dados; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON TABLE auditoria.mapeamento_dados IS 'Atende ao Artigo 37 - Registro de operações de tratamento';


--
-- TOC entry 3731 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN mapeamento_dados.tabela; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON COLUMN auditoria.mapeamento_dados.tabela IS 'Nome da tabela';


--
-- TOC entry 3732 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN mapeamento_dados.campo; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON COLUMN auditoria.mapeamento_dados.campo IS 'Nome do campo/coluna';


--
-- TOC entry 3733 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN mapeamento_dados.categoria; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON COLUMN auditoria.mapeamento_dados.categoria IS '''pessoal'', ''sensivel'', ''infantil''';


--
-- TOC entry 3734 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN mapeamento_dados.tipo_dado; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON COLUMN auditoria.mapeamento_dados.tipo_dado IS '''cpf'', ''nome'', ''endereco'', etc.';


--
-- TOC entry 3735 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN mapeamento_dados.finalidade; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON COLUMN auditoria.mapeamento_dados.finalidade IS 'Por que esse dado é coletado?';


--
-- TOC entry 3736 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN mapeamento_dados.base_legal; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON COLUMN auditoria.mapeamento_dados.base_legal IS '''consentimento'', ''contrato'', ''obrigacao_legal''';


--
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN mapeamento_dados.compartilhado; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON COLUMN auditoria.mapeamento_dados.compartilhado IS 'É compartilhado com terceiros?';


--
-- TOC entry 249 (class 1259 OID 49861)
-- Name: mapeamento_dados_id_mapeamento_dados_seq; Type: SEQUENCE; Schema: auditoria; Owner: -
--

CREATE SEQUENCE auditoria.mapeamento_dados_id_mapeamento_dados_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3738 (class 0 OID 0)
-- Dependencies: 249
-- Name: mapeamento_dados_id_mapeamento_dados_seq; Type: SEQUENCE OWNED BY; Schema: auditoria; Owner: -
--

ALTER SEQUENCE auditoria.mapeamento_dados_id_mapeamento_dados_seq OWNED BY auditoria.mapeamento_dados.id_mapeamento_dados;


--
-- TOC entry 248 (class 1259 OID 49842)
-- Name: soliticacoes_titulares; Type: TABLE; Schema: auditoria; Owner: -
--

CREATE TABLE auditoria.soliticacoes_titulares (
    id_titular integer,
    tipo_solicitacao character varying(50) NOT NULL,
    status character varying(20) NOT NULL,
    prazo_resposta date,
    resposta text,
    data_conclusao timestamp with time zone,
    responsavel_tratamento integer NOT NULL,
    data_solicitacao timestamp with time zone NOT NULL
);


--
-- TOC entry 3739 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN soliticacoes_titulares.tipo_solicitacao; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON COLUMN auditoria.soliticacoes_titulares.tipo_solicitacao IS '-- ''acesso'', ''correcao'', ''exclusao'' etc...';


--
-- TOC entry 3740 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN soliticacoes_titulares.status; Type: COMMENT; Schema: auditoria; Owner: -
--

COMMENT ON COLUMN auditoria.soliticacoes_titulares.status IS '-- ''recebida'', ''em_andamento'', ''concluida''';


--
-- TOC entry 219 (class 1259 OID 16400)
-- Name: tabela_teste; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tabela_teste (
    id integer NOT NULL,
    nome_cliente character varying NOT NULL
);


--
-- TOC entry 230 (class 1259 OID 16921)
-- Name: ficha_atendimento; Type: TABLE; Schema: triagem; Owner: -
--

CREATE TABLE triagem.ficha_atendimento (
    motivo_consulta text,
    conduta text,
    data_atendimento date,
    tipo_atendimento character varying(50),
    id_especialidade_medica_fk integer,
    tipo_queixa text,
    pressao_arterial character varying(100),
    glicemia_capilar character varying(50),
    exame_fisico text,
    dente_tratado character varying(50),
    id_paciente_fk integer NOT NULL,
    id_ficha_atendimento integer NOT NULL,
    id_responsavel_fk integer NOT NULL
);


--
-- TOC entry 3741 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN ficha_atendimento.id_responsavel_fk; Type: COMMENT; Schema: triagem; Owner: -
--

COMMENT ON COLUMN triagem.ficha_atendimento.id_responsavel_fk IS 'Responsável pela criação da ficha de atendimento.';


--
-- TOC entry 256 (class 1259 OID 66479)
-- Name: ficha_atendimento_id_ficha_atendimento_seq; Type: SEQUENCE; Schema: triagem; Owner: -
--

CREATE SEQUENCE triagem.ficha_atendimento_id_ficha_atendimento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3742 (class 0 OID 0)
-- Dependencies: 256
-- Name: ficha_atendimento_id_ficha_atendimento_seq; Type: SEQUENCE OWNED BY; Schema: triagem; Owner: -
--

ALTER SEQUENCE triagem.ficha_atendimento_id_ficha_atendimento_seq OWNED BY triagem.ficha_atendimento.id_ficha_atendimento;


--
-- TOC entry 231 (class 1259 OID 16929)
-- Name: paciente; Type: TABLE; Schema: triagem; Owner: -
--

CREATE TABLE triagem.paciente (
    cns character varying(15),
    nome_completo character varying(255),
    nome_mae character varying(255),
    data_nascimento date,
    sexo character varying(10),
    ativo boolean DEFAULT true,
    raca_cor character varying(2),
    municipio_residencia character varying(20),
    telefone character varying(20),
    cep character varying(20),
    logradouro character varying(100),
    data_cadastro timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    cpf character varying(11),
    id_paciente integer NOT NULL
);


--
-- TOC entry 3743 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN paciente.cns; Type: COMMENT; Schema: triagem; Owner: -
--

COMMENT ON COLUMN triagem.paciente.cns IS '-- Cartão Nacional de Saúde (15 dígitos, válido pelo algoritmo do Ministério da Saúde)';


--
-- TOC entry 3744 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN paciente.nome_completo; Type: COMMENT; Schema: triagem; Owner: -
--

COMMENT ON COLUMN triagem.paciente.nome_completo IS '- Nome completo (como no documento oficial)';


--
-- TOC entry 3745 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN paciente.nome_mae; Type: COMMENT; Schema: triagem; Owner: -
--

COMMENT ON COLUMN triagem.paciente.nome_mae IS '-- Nome da mãe (obrigatório para RNDS em alguns casos)';


--
-- TOC entry 3746 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN paciente.data_nascimento; Type: COMMENT; Schema: triagem; Owner: -
--

COMMENT ON COLUMN triagem.paciente.data_nascimento IS '-- Formato: YYYY-MM-DD';


--
-- TOC entry 3747 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN paciente.sexo; Type: COMMENT; Schema: triagem; Owner: -
--

COMMENT ON COLUMN triagem.paciente.sexo IS '-- **Dados Demográficos (Padrão RNDS)**';


--
-- TOC entry 3748 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN paciente.raca_cor; Type: COMMENT; Schema: triagem; Owner: -
--

COMMENT ON COLUMN triagem.paciente.raca_cor IS '-- Código IBGE (ex: ''01''=Branca, ''02''=Preta)';


--
-- TOC entry 3749 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN paciente.municipio_residencia; Type: COMMENT; Schema: triagem; Owner: -
--

COMMENT ON COLUMN triagem.paciente.municipio_residencia IS '-- Código IBGE do município (7 dígitos)

Não deixei obrigatório pois alguns lugares pode não haver código IBGE';


--
-- TOC entry 3750 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN paciente.logradouro; Type: COMMENT; Schema: triagem; Owner: -
--

COMMENT ON COLUMN triagem.paciente.logradouro IS '-- Rua/Avenida';


--
-- TOC entry 255 (class 1259 OID 58243)
-- Name: paciente_id_paciente_seq; Type: SEQUENCE; Schema: triagem; Owner: -
--

CREATE SEQUENCE triagem.paciente_id_paciente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3751 (class 0 OID 0)
-- Dependencies: 255
-- Name: paciente_id_paciente_seq; Type: SEQUENCE OWNED BY; Schema: triagem; Owner: -
--

ALTER SEQUENCE triagem.paciente_id_paciente_seq OWNED BY triagem.paciente.id_paciente;


--
-- TOC entry 262 (class 1259 OID 66695)
-- Name: vinculo_fichas_atendimento_insumo; Type: TABLE; Schema: triagem; Owner: -
--

CREATE TABLE triagem.vinculo_fichas_atendimento_insumo (
    id_vinculo_fichas_insumo integer NOT NULL,
    id_insumo_fk integer NOT NULL,
    id_fichas_atendimento_fk integer NOT NULL
);


--
-- TOC entry 263 (class 1259 OID 66698)
-- Name: vinculo_fichas_atendimento_insumo_id_vinculo_fichas_insumo_seq; Type: SEQUENCE; Schema: triagem; Owner: -
--

CREATE SEQUENCE triagem.vinculo_fichas_atendimento_insumo_id_vinculo_fichas_insumo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3752 (class 0 OID 0)
-- Dependencies: 263
-- Name: vinculo_fichas_atendimento_insumo_id_vinculo_fichas_insumo_seq; Type: SEQUENCE OWNED BY; Schema: triagem; Owner: -
--

ALTER SEQUENCE triagem.vinculo_fichas_atendimento_insumo_id_vinculo_fichas_insumo_seq OWNED BY triagem.vinculo_fichas_atendimento_insumo.id_vinculo_fichas_insumo;


--
-- TOC entry 3414 (class 2604 OID 25254)
-- Name: enfermagem id_enfermagem; Type: DEFAULT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.enfermagem ALTER COLUMN id_enfermagem SET DEFAULT nextval('administrador.enfermagem_id_enfermagem_seq'::regclass);


--
-- TOC entry 3416 (class 2604 OID 25282)
-- Name: especialidade_medica id_especialidade_medica; Type: DEFAULT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.especialidade_medica ALTER COLUMN id_especialidade_medica SET DEFAULT nextval('administrador.especialidade_medica_id_especialidade_seq'::regclass);


--
-- TOC entry 3405 (class 2604 OID 16539)
-- Name: exames id_exames; Type: DEFAULT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.exames ALTER COLUMN id_exames SET DEFAULT nextval('administrador.exames_id_exame_seq'::regclass);


--
-- TOC entry 3403 (class 2604 OID 16497)
-- Name: expedicao id_expedicao; Type: DEFAULT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.expedicao ALTER COLUMN id_expedicao SET DEFAULT nextval('administrador.expedicao_id_expedicao_seq'::regclass);


--
-- TOC entry 3404 (class 2604 OID 16512)
-- Name: insumos id_insumos; Type: DEFAULT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.insumos ALTER COLUMN id_insumos SET DEFAULT nextval('administrador.insumos_id_insumos_seq'::regclass);


--
-- TOC entry 3412 (class 2604 OID 25228)
-- Name: medicina id_medicina; Type: DEFAULT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.medicina ALTER COLUMN id_medicina SET DEFAULT nextval('administrador.medico_id_medico_seq'::regclass);


--
-- TOC entry 3415 (class 2604 OID 25268)
-- Name: odontologia id_odontologia; Type: DEFAULT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.odontologia ALTER COLUMN id_odontologia SET DEFAULT nextval('administrador.odontologia_id_odonto_seq'::regclass);


--
-- TOC entry 3406 (class 2604 OID 16901)
-- Name: procedimentos id_procedimentos; Type: DEFAULT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.procedimentos ALTER COLUMN id_procedimentos SET DEFAULT nextval('administrador.precedimentos_id_procedimento_seq'::regclass);


--
-- TOC entry 3413 (class 2604 OID 25240)
-- Name: psicologia id_psicologia; Type: DEFAULT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.psicologia ALTER COLUMN id_psicologia SET DEFAULT nextval('administrador.psicologa_id_psicologa_seq'::regclass);


--
-- TOC entry 3401 (class 2604 OID 66533)
-- Name: usuarios id_usuarios; Type: DEFAULT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.usuarios ALTER COLUMN id_usuarios SET DEFAULT nextval('administrador.usuarios_id_usuarios_seq'::regclass);


--
-- TOC entry 3427 (class 2604 OID 66689)
-- Name: vinculo_expedicao_voluntario id_vinculo_expedicao_voluntario; Type: DEFAULT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.vinculo_expedicao_voluntario ALTER COLUMN id_vinculo_expedicao_voluntario SET DEFAULT nextval('administrador.vinculo_expedicao_voluntario_id_vinculo_expedicao_voluntari_seq'::regclass);


--
-- TOC entry 3402 (class 2604 OID 66542)
-- Name: voluntarios id_voluntario; Type: DEFAULT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.voluntarios ALTER COLUMN id_voluntario SET DEFAULT nextval('administrador.voluntarios_id_voluntario_seq'::regclass);


--
-- TOC entry 3417 (class 2604 OID 41593)
-- Name: fila_consulta_medica id_fila_consulta_medica; Type: DEFAULT; Schema: atendimento; Owner: -
--

ALTER TABLE ONLY atendimento.fila_consulta_medica ALTER COLUMN id_fila_consulta_medica SET DEFAULT nextval('atendimento.fila_consulta_medica_id_fila_consulta_medica_seq'::regclass);


--
-- TOC entry 3418 (class 2604 OID 66489)
-- Name: fila_consulta_medica id_ficha_fk; Type: DEFAULT; Schema: atendimento; Owner: -
--

ALTER TABLE ONLY atendimento.fila_consulta_medica ALTER COLUMN id_ficha_fk SET DEFAULT nextval('atendimento.fila_consulta_medica_id_ficha_fk_seq'::regclass);


--
-- TOC entry 3421 (class 2604 OID 49830)
-- Name: consentimentos id_consentimentos; Type: DEFAULT; Schema: auditoria; Owner: -
--

ALTER TABLE ONLY auditoria.consentimentos ALTER COLUMN id_consentimentos SET DEFAULT nextval('auditoria.consentimentos_id_consentimentos_seq'::regclass);


--
-- TOC entry 3426 (class 2604 OID 49887)
-- Name: fluxo_tabelas id_fluxo_tabela; Type: DEFAULT; Schema: auditoria; Owner: -
--

ALTER TABLE ONLY auditoria.fluxo_tabelas ALTER COLUMN id_fluxo_tabela SET DEFAULT nextval('auditoria.fluxo_tabelas_id_fluxo_tabela_seq'::regclass);


--
-- TOC entry 3424 (class 2604 OID 49876)
-- Name: fluxo_tratamento id_fluxo_tratamento; Type: DEFAULT; Schema: auditoria; Owner: -
--

ALTER TABLE ONLY auditoria.fluxo_tratamento ALTER COLUMN id_fluxo_tratamento SET DEFAULT nextval('auditoria.fluxo_tratamento_id_fluxo_tratamento_seq'::regclass);


--
-- TOC entry 3419 (class 2604 OID 41617)
-- Name: log_auditoria id_log; Type: DEFAULT; Schema: auditoria; Owner: -
--

ALTER TABLE ONLY auditoria.log_auditoria ALTER COLUMN id_log SET DEFAULT nextval('auditoria.log_auditoria_id_log_seq'::regclass);


--
-- TOC entry 3422 (class 2604 OID 49865)
-- Name: mapeamento_dados id_mapeamento_dados; Type: DEFAULT; Schema: auditoria; Owner: -
--

ALTER TABLE ONLY auditoria.mapeamento_dados ALTER COLUMN id_mapeamento_dados SET DEFAULT nextval('auditoria.mapeamento_dados_id_mapeamento_dados_seq'::regclass);


--
-- TOC entry 3407 (class 2604 OID 66480)
-- Name: ficha_atendimento id_ficha_atendimento; Type: DEFAULT; Schema: triagem; Owner: -
--

ALTER TABLE ONLY triagem.ficha_atendimento ALTER COLUMN id_ficha_atendimento SET DEFAULT nextval('triagem.ficha_atendimento_id_ficha_atendimento_seq'::regclass);


--
-- TOC entry 3411 (class 2604 OID 58244)
-- Name: paciente id_paciente; Type: DEFAULT; Schema: triagem; Owner: -
--

ALTER TABLE ONLY triagem.paciente ALTER COLUMN id_paciente SET DEFAULT nextval('triagem.paciente_id_paciente_seq'::regclass);


--
-- TOC entry 3428 (class 2604 OID 66699)
-- Name: vinculo_fichas_atendimento_insumo id_vinculo_fichas_insumo; Type: DEFAULT; Schema: triagem; Owner: -
--

ALTER TABLE ONLY triagem.vinculo_fichas_atendimento_insumo ALTER COLUMN id_vinculo_fichas_insumo SET DEFAULT nextval('triagem.vinculo_fichas_atendimento_insumo_id_vinculo_fichas_insumo_seq'::regclass);


--
-- TOC entry 3674 (class 0 OID 25251)
-- Dependencies: 237
-- Data for Name: enfermagem; Type: TABLE DATA; Schema: administrador; Owner: -
--

COPY administrador.enfermagem (id_enfermagem, coren, id_voluntario_fk) FROM stdin;
\.


--
-- TOC entry 3678 (class 0 OID 25279)
-- Dependencies: 241
-- Data for Name: especialidade_medica; Type: TABLE DATA; Schema: administrador; Owner: -
--

COPY administrador.especialidade_medica (id_especialidade_medica, rqe, id_medicina_fk) FROM stdin;
\.


--
-- TOC entry 3664 (class 0 OID 16536)
-- Dependencies: 227
-- Data for Name: exames; Type: TABLE DATA; Schema: administrador; Owner: -
--

COPY administrador.exames (id_exames, nome, descricao, quantidade, status, id_expedicao_fk) FROM stdin;
\.


--
-- TOC entry 3660 (class 0 OID 16494)
-- Dependencies: 223
-- Data for Name: expedicao; Type: TABLE DATA; Schema: administrador; Owner: -
--

COPY administrador.expedicao (id_expedicao, local, inicio, fim, status, nome) FROM stdin;
\.


--
-- TOC entry 3662 (class 0 OID 16509)
-- Dependencies: 225
-- Data for Name: insumos; Type: TABLE DATA; Schema: administrador; Owner: -
--

COPY administrador.insumos (id_insumos, lote, quantidade, id_expedicao_fk) FROM stdin;
\.


--
-- TOC entry 3669 (class 0 OID 25215)
-- Dependencies: 232
-- Data for Name: medicina; Type: TABLE DATA; Schema: administrador; Owner: -
--

COPY administrador.medicina (id_voluntario_fk, id_medicina, crm) FROM stdin;
\.


--
-- TOC entry 3676 (class 0 OID 25265)
-- Dependencies: 239
-- Data for Name: odontologia; Type: TABLE DATA; Schema: administrador; Owner: -
--

COPY administrador.odontologia (id_odontologia, cro, id_voluntario_fk) FROM stdin;
\.


--
-- TOC entry 3666 (class 0 OID 16898)
-- Dependencies: 229
-- Data for Name: procedimentos; Type: TABLE DATA; Schema: administrador; Owner: -
--

COPY administrador.procedimentos (id_procedimentos, nome, descricao, id_expedicao_fk) FROM stdin;
\.


--
-- TOC entry 3672 (class 0 OID 25237)
-- Dependencies: 235
-- Data for Name: psicologia; Type: TABLE DATA; Schema: administrador; Owner: -
--

COPY administrador.psicologia (id_psicologia, crp, id_voluntario_fk) FROM stdin;
\.


--
-- TOC entry 3657 (class 0 OID 16463)
-- Dependencies: 220
-- Data for Name: usuarios; Type: TABLE DATA; Schema: administrador; Owner: -
--

COPY administrador.usuarios (nivel, "user", senha, email, id_usuarios) FROM stdin;
\.


--
-- TOC entry 3697 (class 0 OID 66675)
-- Dependencies: 260
-- Data for Name: vinculo_expedicao_voluntario; Type: TABLE DATA; Schema: administrador; Owner: -
--

COPY administrador.vinculo_expedicao_voluntario (id_expedicao_fk, id_voluntario_fk, id_vinculo_expedicao_voluntario) FROM stdin;
\.


--
-- TOC entry 3658 (class 0 OID 16471)
-- Dependencies: 221
-- Data for Name: voluntarios; Type: TABLE DATA; Schema: administrador; Owner: -
--

COPY administrador.voluntarios (nome, cargo, cpf, id_login_fk, id_voluntario) FROM stdin;
\.


--
-- TOC entry 3679 (class 0 OID 33395)
-- Dependencies: 242
-- Data for Name: fila_consulta_medica; Type: TABLE DATA; Schema: atendimento; Owner: -
--

COPY atendimento.fila_consulta_medica (status, id_medica_fk, id_fila_consulta_medica, id_ficha_fk) FROM stdin;
\.


--
-- TOC entry 3684 (class 0 OID 49827)
-- Dependencies: 247
-- Data for Name: consentimentos; Type: TABLE DATA; Schema: auditoria; Owner: -
--

COPY auditoria.consentimentos (id_consentimentos, versao_termo, tipo_consentimento, dados_consentidos, data_hora_consentimento, meio_captura, ip_captura, data_hora_revogacao, motivo_revogacao, id_paciente_fk) FROM stdin;
\.


--
-- TOC entry 3691 (class 0 OID 49884)
-- Dependencies: 254
-- Data for Name: fluxo_tabelas; Type: TABLE DATA; Schema: auditoria; Owner: -
--

COPY auditoria.fluxo_tabelas (id_fluxo_tabela, fluxo_tratamento_fk, nome_tabela, operacoes, responsavel) FROM stdin;
\.


--
-- TOC entry 3689 (class 0 OID 49873)
-- Dependencies: 252
-- Data for Name: fluxo_tratamento; Type: TABLE DATA; Schema: auditoria; Owner: -
--

COPY auditoria.fluxo_tratamento (id_fluxo_tratamento, nome_fluxo, descricao, origem_dados, categoria_dados, finalidade_primaria, finalidade_secundaria, base_legal, responsavel, registro_impacto) FROM stdin;
\.


--
-- TOC entry 3682 (class 0 OID 41614)
-- Dependencies: 245
-- Data for Name: log_auditoria; Type: TABLE DATA; Schema: auditoria; Owner: -
--

COPY auditoria.log_auditoria (id_log, tabela_afetada, esquema_afetado, id_registro_afetado, tipo_operacao, dados_anteriores, dados_novos, id_usuario_responsavel, ip_conexao, data_hora_operacao) FROM stdin;
\.


--
-- TOC entry 3687 (class 0 OID 49862)
-- Dependencies: 250
-- Data for Name: mapeamento_dados; Type: TABLE DATA; Schema: auditoria; Owner: -
--

COPY auditoria.mapeamento_dados (id_mapeamento_dados, tabela, campo, categoria, tipo_dado, finalidade, base_legal, prazo_retencao, compartilhado, destino_compartilhamento) FROM stdin;
\.


--
-- TOC entry 3685 (class 0 OID 49842)
-- Dependencies: 248
-- Data for Name: soliticacoes_titulares; Type: TABLE DATA; Schema: auditoria; Owner: -
--

COPY auditoria.soliticacoes_titulares (id_titular, tipo_solicitacao, status, prazo_resposta, resposta, data_conclusao, responsavel_tratamento, data_solicitacao) FROM stdin;
\.


--
-- TOC entry 3656 (class 0 OID 16400)
-- Dependencies: 219
-- Data for Name: tabela_teste; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tabela_teste (id, nome_cliente) FROM stdin;
\.


--
-- TOC entry 3667 (class 0 OID 16921)
-- Dependencies: 230
-- Data for Name: ficha_atendimento; Type: TABLE DATA; Schema: triagem; Owner: -
--

COPY triagem.ficha_atendimento (motivo_consulta, conduta, data_atendimento, tipo_atendimento, id_especialidade_medica_fk, tipo_queixa, pressao_arterial, glicemia_capilar, exame_fisico, dente_tratado, id_paciente_fk, id_ficha_atendimento, id_responsavel_fk) FROM stdin;
\.


--
-- TOC entry 3668 (class 0 OID 16929)
-- Dependencies: 231
-- Data for Name: paciente; Type: TABLE DATA; Schema: triagem; Owner: -
--

COPY triagem.paciente (cns, nome_completo, nome_mae, data_nascimento, sexo, ativo, raca_cor, municipio_residencia, telefone, cep, logradouro, data_cadastro, data_atualizacao, cpf, id_paciente) FROM stdin;
\.


--
-- TOC entry 3699 (class 0 OID 66695)
-- Dependencies: 262
-- Data for Name: vinculo_fichas_atendimento_insumo; Type: TABLE DATA; Schema: triagem; Owner: -
--

COPY triagem.vinculo_fichas_atendimento_insumo (id_vinculo_fichas_insumo, id_insumo_fk, id_fichas_atendimento_fk) FROM stdin;
\.


--
-- TOC entry 3753 (class 0 OID 0)
-- Dependencies: 236
-- Name: enfermagem_id_enfermagem_seq; Type: SEQUENCE SET; Schema: administrador; Owner: -
--

SELECT pg_catalog.setval('administrador.enfermagem_id_enfermagem_seq', 1, false);


--
-- TOC entry 3754 (class 0 OID 0)
-- Dependencies: 240
-- Name: especialidade_medica_id_especialidade_seq; Type: SEQUENCE SET; Schema: administrador; Owner: -
--

SELECT pg_catalog.setval('administrador.especialidade_medica_id_especialidade_seq', 1, false);


--
-- TOC entry 3755 (class 0 OID 0)
-- Dependencies: 226
-- Name: exames_id_exame_seq; Type: SEQUENCE SET; Schema: administrador; Owner: -
--

SELECT pg_catalog.setval('administrador.exames_id_exame_seq', 1, false);


--
-- TOC entry 3756 (class 0 OID 0)
-- Dependencies: 222
-- Name: expedicao_id_expedicao_seq; Type: SEQUENCE SET; Schema: administrador; Owner: -
--

SELECT pg_catalog.setval('administrador.expedicao_id_expedicao_seq', 1, true);


--
-- TOC entry 3757 (class 0 OID 0)
-- Dependencies: 224
-- Name: insumos_id_insumos_seq; Type: SEQUENCE SET; Schema: administrador; Owner: -
--

SELECT pg_catalog.setval('administrador.insumos_id_insumos_seq', 1, false);


--
-- TOC entry 3758 (class 0 OID 0)
-- Dependencies: 233
-- Name: medico_id_medico_seq; Type: SEQUENCE SET; Schema: administrador; Owner: -
--

SELECT pg_catalog.setval('administrador.medico_id_medico_seq', 1, false);


--
-- TOC entry 3759 (class 0 OID 0)
-- Dependencies: 238
-- Name: odontologia_id_odonto_seq; Type: SEQUENCE SET; Schema: administrador; Owner: -
--

SELECT pg_catalog.setval('administrador.odontologia_id_odonto_seq', 1, false);


--
-- TOC entry 3760 (class 0 OID 0)
-- Dependencies: 228
-- Name: precedimentos_id_procedimento_seq; Type: SEQUENCE SET; Schema: administrador; Owner: -
--

SELECT pg_catalog.setval('administrador.precedimentos_id_procedimento_seq', 1, false);


--
-- TOC entry 3761 (class 0 OID 0)
-- Dependencies: 234
-- Name: psicologa_id_psicologa_seq; Type: SEQUENCE SET; Schema: administrador; Owner: -
--

SELECT pg_catalog.setval('administrador.psicologa_id_psicologa_seq', 1, false);


--
-- TOC entry 3762 (class 0 OID 0)
-- Dependencies: 258
-- Name: usuarios_id_usuarios_seq; Type: SEQUENCE SET; Schema: administrador; Owner: -
--

SELECT pg_catalog.setval('administrador.usuarios_id_usuarios_seq', 1, false);


--
-- TOC entry 3763 (class 0 OID 0)
-- Dependencies: 261
-- Name: vinculo_expedicao_voluntario_id_vinculo_expedicao_voluntari_seq; Type: SEQUENCE SET; Schema: administrador; Owner: -
--

SELECT pg_catalog.setval('administrador.vinculo_expedicao_voluntario_id_vinculo_expedicao_voluntari_seq', 1, false);


--
-- TOC entry 3764 (class 0 OID 0)
-- Dependencies: 259
-- Name: voluntarios_id_voluntario_seq; Type: SEQUENCE SET; Schema: administrador; Owner: -
--

SELECT pg_catalog.setval('administrador.voluntarios_id_voluntario_seq', 1, false);


--
-- TOC entry 3765 (class 0 OID 0)
-- Dependencies: 257
-- Name: fila_consulta_medica_id_ficha_fk_seq; Type: SEQUENCE SET; Schema: atendimento; Owner: -
--

SELECT pg_catalog.setval('atendimento.fila_consulta_medica_id_ficha_fk_seq', 1, false);


--
-- TOC entry 3766 (class 0 OID 0)
-- Dependencies: 243
-- Name: fila_consulta_medica_id_fila_consulta_medica_seq; Type: SEQUENCE SET; Schema: atendimento; Owner: -
--

SELECT pg_catalog.setval('atendimento.fila_consulta_medica_id_fila_consulta_medica_seq', 1, false);


--
-- TOC entry 3767 (class 0 OID 0)
-- Dependencies: 246
-- Name: consentimentos_id_consentimentos_seq; Type: SEQUENCE SET; Schema: auditoria; Owner: -
--

SELECT pg_catalog.setval('auditoria.consentimentos_id_consentimentos_seq', 1, false);


--
-- TOC entry 3768 (class 0 OID 0)
-- Dependencies: 253
-- Name: fluxo_tabelas_id_fluxo_tabela_seq; Type: SEQUENCE SET; Schema: auditoria; Owner: -
--

SELECT pg_catalog.setval('auditoria.fluxo_tabelas_id_fluxo_tabela_seq', 1, false);


--
-- TOC entry 3769 (class 0 OID 0)
-- Dependencies: 251
-- Name: fluxo_tratamento_id_fluxo_tratamento_seq; Type: SEQUENCE SET; Schema: auditoria; Owner: -
--

SELECT pg_catalog.setval('auditoria.fluxo_tratamento_id_fluxo_tratamento_seq', 1, false);


--
-- TOC entry 3770 (class 0 OID 0)
-- Dependencies: 244
-- Name: log_auditoria_id_log_seq; Type: SEQUENCE SET; Schema: auditoria; Owner: -
--

SELECT pg_catalog.setval('auditoria.log_auditoria_id_log_seq', 1, true);


--
-- TOC entry 3771 (class 0 OID 0)
-- Dependencies: 249
-- Name: mapeamento_dados_id_mapeamento_dados_seq; Type: SEQUENCE SET; Schema: auditoria; Owner: -
--

SELECT pg_catalog.setval('auditoria.mapeamento_dados_id_mapeamento_dados_seq', 1, false);


--
-- TOC entry 3772 (class 0 OID 0)
-- Dependencies: 256
-- Name: ficha_atendimento_id_ficha_atendimento_seq; Type: SEQUENCE SET; Schema: triagem; Owner: -
--

SELECT pg_catalog.setval('triagem.ficha_atendimento_id_ficha_atendimento_seq', 1, true);


--
-- TOC entry 3773 (class 0 OID 0)
-- Dependencies: 255
-- Name: paciente_id_paciente_seq; Type: SEQUENCE SET; Schema: triagem; Owner: -
--

SELECT pg_catalog.setval('triagem.paciente_id_paciente_seq', 1, true);


--
-- TOC entry 3774 (class 0 OID 0)
-- Dependencies: 263
-- Name: vinculo_fichas_atendimento_insumo_id_vinculo_fichas_insumo_seq; Type: SEQUENCE SET; Schema: triagem; Owner: -
--

SELECT pg_catalog.setval('triagem.vinculo_fichas_atendimento_insumo_id_vinculo_fichas_insumo_seq', 1, false);


--
-- TOC entry 3455 (class 2606 OID 25258)
-- Name: enfermagem enfermagem_pk; Type: CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.enfermagem
    ADD CONSTRAINT enfermagem_pk PRIMARY KEY (id_enfermagem);


--
-- TOC entry 3459 (class 2606 OID 25286)
-- Name: especialidade_medica especialidade_medica_pk; Type: CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.especialidade_medica
    ADD CONSTRAINT especialidade_medica_pk PRIMARY KEY (id_especialidade_medica);


--
-- TOC entry 3443 (class 2606 OID 16543)
-- Name: exames exames_pk; Type: CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.exames
    ADD CONSTRAINT exames_pk PRIMARY KEY (id_exames);


--
-- TOC entry 3439 (class 2606 OID 16502)
-- Name: expedicao expedicao_pk; Type: CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.expedicao
    ADD CONSTRAINT expedicao_pk PRIMARY KEY (id_expedicao);


--
-- TOC entry 3451 (class 2606 OID 25233)
-- Name: medicina id_medicina_pk; Type: CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.medicina
    ADD CONSTRAINT id_medicina_pk PRIMARY KEY (id_medicina);


--
-- TOC entry 3441 (class 2606 OID 16516)
-- Name: insumos insumos_pk; Type: CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.insumos
    ADD CONSTRAINT insumos_pk PRIMARY KEY (id_insumos);


--
-- TOC entry 3457 (class 2606 OID 25272)
-- Name: odontologia odontologia_pk; Type: CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.odontologia
    ADD CONSTRAINT odontologia_pk PRIMARY KEY (id_odontologia);


--
-- TOC entry 3445 (class 2606 OID 16905)
-- Name: procedimentos precedimentos_pk; Type: CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.procedimentos
    ADD CONSTRAINT precedimentos_pk PRIMARY KEY (id_procedimentos);


--
-- TOC entry 3453 (class 2606 OID 25244)
-- Name: psicologia psicologa_pk; Type: CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.psicologia
    ADD CONSTRAINT psicologa_pk PRIMARY KEY (id_psicologia);


--
-- TOC entry 3433 (class 2606 OID 66540)
-- Name: usuarios usuarios_pk; Type: CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.usuarios
    ADD CONSTRAINT usuarios_pk PRIMARY KEY (id_usuarios);


--
-- TOC entry 3473 (class 2606 OID 66694)
-- Name: vinculo_expedicao_voluntario vinculo_expedicao_voluntario_pk; Type: CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.vinculo_expedicao_voluntario
    ADD CONSTRAINT vinculo_expedicao_voluntario_pk PRIMARY KEY (id_vinculo_expedicao_voluntario);


--
-- TOC entry 3437 (class 2606 OID 66551)
-- Name: voluntarios voluntarios_pk; Type: CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.voluntarios
    ADD CONSTRAINT voluntarios_pk PRIMARY KEY (id_voluntario);


--
-- TOC entry 3461 (class 2606 OID 41600)
-- Name: fila_consulta_medica fila_consulta_medica_pk; Type: CONSTRAINT; Schema: atendimento; Owner: -
--

ALTER TABLE ONLY atendimento.fila_consulta_medica
    ADD CONSTRAINT fila_consulta_medica_pk PRIMARY KEY (id_fila_consulta_medica);


--
-- TOC entry 3465 (class 2606 OID 49834)
-- Name: consentimentos consentimentos_pk; Type: CONSTRAINT; Schema: auditoria; Owner: -
--

ALTER TABLE ONLY auditoria.consentimentos
    ADD CONSTRAINT consentimentos_pk PRIMARY KEY (id_consentimentos);


--
-- TOC entry 3471 (class 2606 OID 49889)
-- Name: fluxo_tabelas fluxo_tabelas_pk; Type: CONSTRAINT; Schema: auditoria; Owner: -
--

ALTER TABLE ONLY auditoria.fluxo_tabelas
    ADD CONSTRAINT fluxo_tabelas_pk PRIMARY KEY (id_fluxo_tabela);


--
-- TOC entry 3469 (class 2606 OID 49881)
-- Name: fluxo_tratamento fluxo_tratamento_pk; Type: CONSTRAINT; Schema: auditoria; Owner: -
--

ALTER TABLE ONLY auditoria.fluxo_tratamento
    ADD CONSTRAINT fluxo_tratamento_pk PRIMARY KEY (id_fluxo_tratamento);


--
-- TOC entry 3463 (class 2606 OID 41622)
-- Name: log_auditoria log_auditoria_pkey; Type: CONSTRAINT; Schema: auditoria; Owner: -
--

ALTER TABLE ONLY auditoria.log_auditoria
    ADD CONSTRAINT log_auditoria_pkey PRIMARY KEY (id_log);


--
-- TOC entry 3467 (class 2606 OID 49870)
-- Name: mapeamento_dados mapeamento_dados_pk; Type: CONSTRAINT; Schema: auditoria; Owner: -
--

ALTER TABLE ONLY auditoria.mapeamento_dados
    ADD CONSTRAINT mapeamento_dados_pk PRIMARY KEY (id_mapeamento_dados);


--
-- TOC entry 3431 (class 2606 OID 16406)
-- Name: tabela_teste tabela_teste_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tabela_teste
    ADD CONSTRAINT tabela_teste_pk PRIMARY KEY (id);


--
-- TOC entry 3447 (class 2606 OID 66487)
-- Name: ficha_atendimento ficha_atendimento_pk; Type: CONSTRAINT; Schema: triagem; Owner: -
--

ALTER TABLE ONLY triagem.ficha_atendimento
    ADD CONSTRAINT ficha_atendimento_pk PRIMARY KEY (id_ficha_atendimento);


--
-- TOC entry 3449 (class 2606 OID 58253)
-- Name: paciente id_paciente_pk; Type: CONSTRAINT; Schema: triagem; Owner: -
--

ALTER TABLE ONLY triagem.paciente
    ADD CONSTRAINT id_paciente_pk PRIMARY KEY (id_paciente);


--
-- TOC entry 3475 (class 2606 OID 66704)
-- Name: vinculo_fichas_atendimento_insumo vinculo_fichas_atendimento_insumo_pk; Type: CONSTRAINT; Schema: triagem; Owner: -
--

ALTER TABLE ONLY triagem.vinculo_fichas_atendimento_insumo
    ADD CONSTRAINT vinculo_fichas_atendimento_insumo_pk PRIMARY KEY (id_vinculo_fichas_insumo);


--
-- TOC entry 3434 (class 1259 OID 41610)
-- Name: voluntarios_cpf_idx; Type: INDEX; Schema: administrador; Owner: -
--

CREATE UNIQUE INDEX voluntarios_cpf_idx ON administrador.voluntarios USING btree (cpf);


--
-- TOC entry 3435 (class 1259 OID 41611)
-- Name: voluntarios_nome_idx; Type: INDEX; Schema: administrador; Owner: -
--

CREATE INDEX voluntarios_nome_idx ON administrador.voluntarios USING btree (nome);


--
-- TOC entry 3505 (class 2620 OID 49825)
-- Name: enfermagem tr_auditar_enfermagem; Type: TRIGGER; Schema: administrador; Owner: -
--

CREATE TRIGGER tr_auditar_enfermagem AFTER INSERT OR DELETE OR UPDATE ON administrador.enfermagem FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3507 (class 2620 OID 49824)
-- Name: especialidade_medica tr_auditar_especialidade_medica; Type: TRIGGER; Schema: administrador; Owner: -
--

CREATE TRIGGER tr_auditar_especialidade_medica AFTER INSERT OR DELETE OR UPDATE ON administrador.especialidade_medica FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3499 (class 2620 OID 49823)
-- Name: exames tr_auditar_exames; Type: TRIGGER; Schema: administrador; Owner: -
--

CREATE TRIGGER tr_auditar_exames AFTER INSERT OR DELETE OR UPDATE ON administrador.exames FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3497 (class 2620 OID 49822)
-- Name: expedicao tr_auditar_expedicao; Type: TRIGGER; Schema: administrador; Owner: -
--

CREATE TRIGGER tr_auditar_expedicao AFTER INSERT OR DELETE OR UPDATE ON administrador.expedicao FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3498 (class 2620 OID 49821)
-- Name: insumos tr_auditar_insumos; Type: TRIGGER; Schema: administrador; Owner: -
--

CREATE TRIGGER tr_auditar_insumos AFTER INSERT OR DELETE OR UPDATE ON administrador.insumos FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3503 (class 2620 OID 49820)
-- Name: medicina tr_auditar_medicina; Type: TRIGGER; Schema: administrador; Owner: -
--

CREATE TRIGGER tr_auditar_medicina AFTER INSERT OR DELETE OR UPDATE ON administrador.medicina FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3506 (class 2620 OID 49819)
-- Name: odontologia tr_auditar_odontologia; Type: TRIGGER; Schema: administrador; Owner: -
--

CREATE TRIGGER tr_auditar_odontologia AFTER INSERT OR DELETE OR UPDATE ON administrador.odontologia FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3500 (class 2620 OID 49818)
-- Name: procedimentos tr_auditar_procedimentos; Type: TRIGGER; Schema: administrador; Owner: -
--

CREATE TRIGGER tr_auditar_procedimentos AFTER INSERT OR DELETE OR UPDATE ON administrador.procedimentos FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3504 (class 2620 OID 49817)
-- Name: psicologia tr_auditar_psicologia; Type: TRIGGER; Schema: administrador; Owner: -
--

CREATE TRIGGER tr_auditar_psicologia AFTER INSERT OR DELETE OR UPDATE ON administrador.psicologia FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3496 (class 2620 OID 49813)
-- Name: usuarios tr_auditar_usuarios; Type: TRIGGER; Schema: administrador; Owner: -
--

CREATE TRIGGER tr_auditar_usuarios AFTER INSERT OR DELETE OR UPDATE ON administrador.usuarios FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3508 (class 2620 OID 49840)
-- Name: consentimentos tr_auditar_consentimentos; Type: TRIGGER; Schema: auditoria; Owner: -
--

CREATE TRIGGER tr_auditar_consentimentos AFTER INSERT OR DELETE OR UPDATE ON auditoria.consentimentos FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3512 (class 2620 OID 49895)
-- Name: fluxo_tabelas tr_auditar_fluxo_tabelas; Type: TRIGGER; Schema: auditoria; Owner: -
--

CREATE TRIGGER tr_auditar_fluxo_tabelas AFTER INSERT OR DELETE OR UPDATE ON auditoria.fluxo_tabelas FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3511 (class 2620 OID 49882)
-- Name: fluxo_tratamento tr_auditar_fluxo_tratamento; Type: TRIGGER; Schema: auditoria; Owner: -
--

CREATE TRIGGER tr_auditar_fluxo_tratamento AFTER INSERT OR DELETE OR UPDATE ON auditoria.fluxo_tratamento FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3510 (class 2620 OID 49871)
-- Name: mapeamento_dados tr_auditar_mapeamento_dados; Type: TRIGGER; Schema: auditoria; Owner: -
--

CREATE TRIGGER tr_auditar_mapeamento_dados AFTER INSERT OR DELETE OR UPDATE ON auditoria.mapeamento_dados FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3509 (class 2620 OID 49860)
-- Name: soliticacoes_titulares tr_auditar_solicitacao_titulares; Type: TRIGGER; Schema: auditoria; Owner: -
--

CREATE TRIGGER tr_auditar_solicitacao_titulares AFTER INSERT OR DELETE OR UPDATE ON auditoria.soliticacoes_titulares FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3501 (class 2620 OID 49815)
-- Name: ficha_atendimento tr_auditar_ficha_paciente; Type: TRIGGER; Schema: triagem; Owner: -
--

CREATE TRIGGER tr_auditar_ficha_paciente AFTER INSERT OR DELETE OR UPDATE ON triagem.ficha_atendimento FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3502 (class 2620 OID 49814)
-- Name: paciente tr_auditar_paciente; Type: TRIGGER; Schema: triagem; Owner: -
--

CREATE TRIGGER tr_auditar_paciente AFTER INSERT OR DELETE OR UPDATE ON triagem.paciente FOR EACH ROW EXECUTE FUNCTION auditoria.func_auditar_alteracoes();


--
-- TOC entry 3485 (class 2606 OID 66557)
-- Name: enfermagem enfermagem_voluntarios_fk; Type: FK CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.enfermagem
    ADD CONSTRAINT enfermagem_voluntarios_fk FOREIGN KEY (id_voluntario_fk) REFERENCES administrador.voluntarios(id_voluntario);


--
-- TOC entry 3487 (class 2606 OID 25287)
-- Name: especialidade_medica especialidade_medica_medicina_fk; Type: FK CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.especialidade_medica
    ADD CONSTRAINT especialidade_medica_medicina_fk FOREIGN KEY (id_medicina_fk) REFERENCES administrador.medicina(id_medicina);


--
-- TOC entry 3478 (class 2606 OID 17034)
-- Name: exames exames_expedicao_fk; Type: FK CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.exames
    ADD CONSTRAINT exames_expedicao_fk FOREIGN KEY (id_expedicao_fk) REFERENCES administrador.expedicao(id_expedicao);


--
-- TOC entry 3477 (class 2606 OID 17044)
-- Name: insumos insumos_expedicao_fk; Type: FK CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.insumos
    ADD CONSTRAINT insumos_expedicao_fk FOREIGN KEY (id_expedicao_fk) REFERENCES administrador.expedicao(id_expedicao);


--
-- TOC entry 3483 (class 2606 OID 66562)
-- Name: medicina medicina_voluntarios_fk; Type: FK CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.medicina
    ADD CONSTRAINT medicina_voluntarios_fk FOREIGN KEY (id_voluntario_fk) REFERENCES administrador.voluntarios(id_voluntario);


--
-- TOC entry 3486 (class 2606 OID 66567)
-- Name: odontologia odontologia_voluntarios_fk; Type: FK CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.odontologia
    ADD CONSTRAINT odontologia_voluntarios_fk FOREIGN KEY (id_voluntario_fk) REFERENCES administrador.voluntarios(id_voluntario);


--
-- TOC entry 3479 (class 2606 OID 17039)
-- Name: procedimentos precedimentos_expedicao_fk; Type: FK CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.procedimentos
    ADD CONSTRAINT precedimentos_expedicao_fk FOREIGN KEY (id_expedicao_fk) REFERENCES administrador.expedicao(id_expedicao);


--
-- TOC entry 3484 (class 2606 OID 66572)
-- Name: psicologia psicologia_voluntarios_fk; Type: FK CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.psicologia
    ADD CONSTRAINT psicologia_voluntarios_fk FOREIGN KEY (id_voluntario_fk) REFERENCES administrador.voluntarios(id_voluntario);


--
-- TOC entry 3492 (class 2606 OID 66683)
-- Name: vinculo_expedicao_voluntario vinculo_expedicao_voluntario_expedicao_fk; Type: FK CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.vinculo_expedicao_voluntario
    ADD CONSTRAINT vinculo_expedicao_voluntario_expedicao_fk FOREIGN KEY (id_expedicao_fk) REFERENCES administrador.expedicao(id_expedicao);


--
-- TOC entry 3493 (class 2606 OID 66678)
-- Name: vinculo_expedicao_voluntario vinculo_expedicao_voluntario_voluntarios_fk; Type: FK CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.vinculo_expedicao_voluntario
    ADD CONSTRAINT vinculo_expedicao_voluntario_voluntarios_fk FOREIGN KEY (id_voluntario_fk) REFERENCES administrador.voluntarios(id_voluntario);


--
-- TOC entry 3476 (class 2606 OID 66577)
-- Name: voluntarios voluntarios_usuarios_fk; Type: FK CONSTRAINT; Schema: administrador; Owner: -
--

ALTER TABLE ONLY administrador.voluntarios
    ADD CONSTRAINT voluntarios_usuarios_fk FOREIGN KEY (id_login_fk) REFERENCES administrador.usuarios(id_usuarios);


--
-- TOC entry 3488 (class 2606 OID 66496)
-- Name: fila_consulta_medica fila_consulta_medica_ficha_atendimento_fk; Type: FK CONSTRAINT; Schema: atendimento; Owner: -
--

ALTER TABLE ONLY atendimento.fila_consulta_medica
    ADD CONSTRAINT fila_consulta_medica_ficha_atendimento_fk FOREIGN KEY (id_ficha_fk) REFERENCES triagem.ficha_atendimento(id_ficha_atendimento);


--
-- TOC entry 3489 (class 2606 OID 41587)
-- Name: fila_consulta_medica fila_consulta_medica_medicina_fk; Type: FK CONSTRAINT; Schema: atendimento; Owner: -
--

ALTER TABLE ONLY atendimento.fila_consulta_medica
    ADD CONSTRAINT fila_consulta_medica_medicina_fk FOREIGN KEY (id_medica_fk) REFERENCES administrador.medicina(id_medicina);


--
-- TOC entry 3490 (class 2606 OID 58274)
-- Name: consentimentos consentimentos_paciente_fk; Type: FK CONSTRAINT; Schema: auditoria; Owner: -
--

ALTER TABLE ONLY auditoria.consentimentos
    ADD CONSTRAINT consentimentos_paciente_fk FOREIGN KEY (id_paciente_fk) REFERENCES triagem.paciente(id_paciente);


--
-- TOC entry 3491 (class 2606 OID 49890)
-- Name: fluxo_tabelas fluxo_tabelas_fluxo_tratamento_fk; Type: FK CONSTRAINT; Schema: auditoria; Owner: -
--

ALTER TABLE ONLY auditoria.fluxo_tabelas
    ADD CONSTRAINT fluxo_tabelas_fluxo_tratamento_fk FOREIGN KEY (fluxo_tratamento_fk) REFERENCES auditoria.fluxo_tratamento(id_fluxo_tratamento);


--
-- TOC entry 3480 (class 2606 OID 58053)
-- Name: ficha_atendimento ficha_atendimento_especialidade_medica_fk; Type: FK CONSTRAINT; Schema: triagem; Owner: -
--

ALTER TABLE ONLY triagem.ficha_atendimento
    ADD CONSTRAINT ficha_atendimento_especialidade_medica_fk FOREIGN KEY (id_especialidade_medica_fk) REFERENCES administrador.especialidade_medica(id_especialidade_medica);


--
-- TOC entry 3481 (class 2606 OID 58269)
-- Name: ficha_atendimento ficha_atendimento_paciente_fk; Type: FK CONSTRAINT; Schema: triagem; Owner: -
--

ALTER TABLE ONLY triagem.ficha_atendimento
    ADD CONSTRAINT ficha_atendimento_paciente_fk FOREIGN KEY (id_paciente_fk) REFERENCES triagem.paciente(id_paciente);


--
-- TOC entry 3482 (class 2606 OID 66584)
-- Name: ficha_atendimento ficha_atendimento_voluntarios_fk; Type: FK CONSTRAINT; Schema: triagem; Owner: -
--

ALTER TABLE ONLY triagem.ficha_atendimento
    ADD CONSTRAINT ficha_atendimento_voluntarios_fk FOREIGN KEY (id_responsavel_fk) REFERENCES administrador.voluntarios(id_voluntario);


--
-- TOC entry 3494 (class 2606 OID 66710)
-- Name: vinculo_fichas_atendimento_insumo vinculo_fichas_atendimento_insumo_ficha_atendimento_fk; Type: FK CONSTRAINT; Schema: triagem; Owner: -
--

ALTER TABLE ONLY triagem.vinculo_fichas_atendimento_insumo
    ADD CONSTRAINT vinculo_fichas_atendimento_insumo_ficha_atendimento_fk FOREIGN KEY (id_fichas_atendimento_fk) REFERENCES triagem.ficha_atendimento(id_ficha_atendimento);


--
-- TOC entry 3495 (class 2606 OID 66705)
-- Name: vinculo_fichas_atendimento_insumo vinculo_fichas_atendimento_insumo_insumos_fk; Type: FK CONSTRAINT; Schema: triagem; Owner: -
--

ALTER TABLE ONLY triagem.vinculo_fichas_atendimento_insumo
    ADD CONSTRAINT vinculo_fichas_atendimento_insumo_insumos_fk FOREIGN KEY (id_insumo_fk) REFERENCES administrador.insumos(id_insumos);


