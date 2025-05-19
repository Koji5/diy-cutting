SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: tg_h_error_logs_compress(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tg_h_error_logs_compress() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- NEW.stacktrace はコントローラ側で text として渡す想定
  NEW.stacktrace_compressed := compress(NEW.stacktrace);
  NEW.stack_head            := left(NEW.stacktrace, 1024); -- 先頭 1 KB
  NEW.stacktrace            := NULL;                       -- 不要なら NULL
  RETURN NEW;
END
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_details (
    user_id bigint NOT NULL,
    nickname character varying(50),
    icon_url character varying(255),
    department character varying(100),
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: affiliate_commissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.affiliate_commissions (
    id bigint NOT NULL,
    affiliate_user_id bigint NOT NULL,
    referred_user_id bigint NOT NULL,
    order_id bigint NOT NULL,
    order_amount numeric(18,4) DEFAULT 0.0 NOT NULL,
    rate_pct numeric(5,2) DEFAULT 0.0 NOT NULL,
    commission_amount numeric(18,4) DEFAULT 0.0 NOT NULL,
    paid_flag boolean DEFAULT false NOT NULL,
    paid_at timestamp(6) without time zone,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_aff_comm_amount_non_negative CHECK ((commission_amount >= (0)::numeric)),
    CONSTRAINT chk_aff_comm_paid_consistency CHECK (((NOT paid_flag) OR (paid_at IS NOT NULL)))
);


--
-- Name: affiliate_commissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.affiliate_commissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: affiliate_commissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.affiliate_commissions_id_seq OWNED BY public.affiliate_commissions.id;


--
-- Name: affiliate_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.affiliate_details (
    user_id bigint NOT NULL,
    name character varying(100) NOT NULL,
    name_kana character varying(255),
    postal_code character varying(8) NOT NULL,
    prefecture_code character varying(2) NOT NULL,
    city_code character varying(5) NOT NULL,
    address_line character varying(200) NOT NULL,
    phone_number character varying(30),
    invoice_number character varying(20),
    bank_name character varying(100),
    account_type smallint,
    account_number character varying(30),
    account_holder character varying(100),
    commission_rate numeric(5,2) DEFAULT 3.0 NOT NULL,
    payout_threshold numeric(18,4) DEFAULT 5000.0 NOT NULL,
    unpaid_balance numeric(18,4) DEFAULT 0.0 NOT NULL,
    last_paid_at timestamp(6) without time zone,
    stripe_account_id character varying(255) NOT NULL,
    charges_enabled boolean DEFAULT false NOT NULL,
    payouts_enabled boolean DEFAULT false NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: affiliate_signups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.affiliate_signups (
    id bigint NOT NULL,
    affiliate_user_id bigint NOT NULL,
    affiliate_click_id bigint,
    signup_user_id bigint NOT NULL,
    signup_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: affiliate_signups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.affiliate_signups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: affiliate_signups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.affiliate_signups_id_seq OWNED BY public.affiliate_signups.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: article_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.article_comments (
    id bigint NOT NULL,
    article_id bigint NOT NULL,
    parent_id bigint,
    author_type character varying(20) NOT NULL,
    author_id bigint NOT NULL,
    body text NOT NULL,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_article_comments_author_type CHECK (((author_type)::text = ANY ((ARRAY['MemberDetail'::character varying, 'VendorDetail'::character varying, 'AdminDetail'::character varying, 'AffiliateDetail'::character varying])::text[])))
);


--
-- Name: article_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.article_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: article_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.article_comments_id_seq OWNED BY public.article_comments.id;


--
-- Name: article_likes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.article_likes (
    id bigint NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: article_likes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.article_likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: article_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.article_likes_id_seq OWNED BY public.article_likes.id;


--
-- Name: article_media; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.article_media (
    id bigint NOT NULL,
    article_id bigint NOT NULL,
    media_type smallint NOT NULL,
    file_url character varying(500) NOT NULL,
    caption character varying(150),
    "position" smallint,
    meta_json jsonb DEFAULT '"{}"'::jsonb,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: article_media_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.article_media_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: article_media_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.article_media_id_seq OWNED BY public.article_media.id;


--
-- Name: articles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.articles (
    id bigint NOT NULL,
    author_type character varying(20) NOT NULL,
    author_id bigint NOT NULL,
    category smallint NOT NULL,
    title character varying(150) NOT NULL,
    content_blocks jsonb DEFAULT '"{}"'::jsonb NOT NULL,
    order_id bigint,
    likes_count integer DEFAULT 0 NOT NULL,
    replies_count integer DEFAULT 0 NOT NULL,
    views_count integer DEFAULT 0 NOT NULL,
    published_at timestamp(6) without time zone,
    is_draft boolean DEFAULT false NOT NULL,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_articles_author_type CHECK (((author_type)::text = ANY ((ARRAY['MemberDetail'::character varying, 'VendorDetail'::character varying, 'AdminDetail'::character varying, 'AffiliateDetail'::character varying])::text[])))
);


--
-- Name: articles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.articles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: articles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.articles_id_seq OWNED BY public.articles.id;


--
-- Name: h_affiliate_clicks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_affiliate_clicks (
    id bigint NOT NULL,
    affiliate_user_id bigint NOT NULL,
    click_token uuid NOT NULL,
    referrer_url character varying(500),
    landing_url character varying(500),
    ip_address inet,
    user_agent character varying(255),
    clicked_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_affiliate_clicks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.h_affiliate_clicks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: h_affiliate_clicks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.h_affiliate_clicks_id_seq OWNED BY public.h_affiliate_clicks.id;


--
-- Name: h_article_views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_article_views (
    id bigint NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint,
    ip_address inet,
    viewed_at timestamp with time zone NOT NULL,
    ua_hash character(32),
    processed_flag boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
)
PARTITION BY RANGE (viewed_at);


--
-- Name: h_article_views_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.h_article_views_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: h_article_views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.h_article_views_id_seq OWNED BY public.h_article_views.id;


--
-- Name: h_article_views_202505; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_article_views_202505 (
    id bigint DEFAULT nextval('public.h_article_views_id_seq'::regclass) NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint,
    ip_address inet,
    viewed_at timestamp with time zone NOT NULL,
    ua_hash character(32),
    processed_flag boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_article_views_202506; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_article_views_202506 (
    id bigint DEFAULT nextval('public.h_article_views_id_seq'::regclass) NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint,
    ip_address inet,
    viewed_at timestamp with time zone NOT NULL,
    ua_hash character(32),
    processed_flag boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_article_views_202507; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_article_views_202507 (
    id bigint DEFAULT nextval('public.h_article_views_id_seq'::regclass) NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint,
    ip_address inet,
    viewed_at timestamp with time zone NOT NULL,
    ua_hash character(32),
    processed_flag boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_article_views_202508; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_article_views_202508 (
    id bigint DEFAULT nextval('public.h_article_views_id_seq'::regclass) NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint,
    ip_address inet,
    viewed_at timestamp with time zone NOT NULL,
    ua_hash character(32),
    processed_flag boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_article_views_202509; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_article_views_202509 (
    id bigint DEFAULT nextval('public.h_article_views_id_seq'::regclass) NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint,
    ip_address inet,
    viewed_at timestamp with time zone NOT NULL,
    ua_hash character(32),
    processed_flag boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_article_views_202510; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_article_views_202510 (
    id bigint DEFAULT nextval('public.h_article_views_id_seq'::regclass) NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint,
    ip_address inet,
    viewed_at timestamp with time zone NOT NULL,
    ua_hash character(32),
    processed_flag boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_article_views_202511; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_article_views_202511 (
    id bigint DEFAULT nextval('public.h_article_views_id_seq'::regclass) NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint,
    ip_address inet,
    viewed_at timestamp with time zone NOT NULL,
    ua_hash character(32),
    processed_flag boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_article_views_202512; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_article_views_202512 (
    id bigint DEFAULT nextval('public.h_article_views_id_seq'::regclass) NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint,
    ip_address inet,
    viewed_at timestamp with time zone NOT NULL,
    ua_hash character(32),
    processed_flag boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_article_views_202601; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_article_views_202601 (
    id bigint DEFAULT nextval('public.h_article_views_id_seq'::regclass) NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint,
    ip_address inet,
    viewed_at timestamp with time zone NOT NULL,
    ua_hash character(32),
    processed_flag boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_article_views_202602; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_article_views_202602 (
    id bigint DEFAULT nextval('public.h_article_views_id_seq'::regclass) NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint,
    ip_address inet,
    viewed_at timestamp with time zone NOT NULL,
    ua_hash character(32),
    processed_flag boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_article_views_202603; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_article_views_202603 (
    id bigint DEFAULT nextval('public.h_article_views_id_seq'::regclass) NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint,
    ip_address inet,
    viewed_at timestamp with time zone NOT NULL,
    ua_hash character(32),
    processed_flag boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_article_views_202604; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_article_views_202604 (
    id bigint DEFAULT nextval('public.h_article_views_id_seq'::regclass) NOT NULL,
    article_id bigint NOT NULL,
    user_id bigint,
    ip_address inet,
    viewed_at timestamp with time zone NOT NULL,
    ua_hash character(32),
    processed_flag boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_audit_trails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_audit_trails (
    id bigint NOT NULL,
    table_name character varying(60) NOT NULL,
    pk_value text NOT NULL,
    action character(1) NOT NULL,
    changed_by bigint,
    before_json jsonb,
    after_json jsonb,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT h_audit_trails_action_check CHECK ((action = ANY (ARRAY['I'::bpchar, 'U'::bpchar, 'D'::bpchar])))
)
PARTITION BY RANGE (changed_at);


--
-- Name: h_audit_trails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.h_audit_trails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: h_audit_trails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.h_audit_trails_id_seq OWNED BY public.h_audit_trails.id;


--
-- Name: h_audit_trails_202505; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_audit_trails_202505 (
    id bigint DEFAULT nextval('public.h_audit_trails_id_seq'::regclass) NOT NULL,
    table_name character varying(60) NOT NULL,
    pk_value text NOT NULL,
    action character(1) NOT NULL,
    changed_by bigint,
    before_json jsonb,
    after_json jsonb,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT h_audit_trails_action_check CHECK ((action = ANY (ARRAY['I'::bpchar, 'U'::bpchar, 'D'::bpchar])))
);


--
-- Name: h_error_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_error_logs (
    id bigint NOT NULL,
    error_class character varying(120) NOT NULL,
    message text NOT NULL,
    stacktrace_compressed bytea NOT NULL,
    stack_head text,
    request_path character varying(255),
    http_method character(6),
    status_code smallint DEFAULT 500 NOT NULL,
    params_json jsonb,
    user_id bigint,
    request_id character(36),
    ip_address inet,
    user_agent character varying(255),
    server_name character varying(60),
    environment character(10) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT h_error_logs_environment_check CHECK ((environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])))
)
PARTITION BY RANGE (occurred_at);


--
-- Name: h_error_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.h_error_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: h_error_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.h_error_logs_id_seq OWNED BY public.h_error_logs.id;


--
-- Name: h_error_logs_202505; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_error_logs_202505 (
    id bigint DEFAULT nextval('public.h_error_logs_id_seq'::regclass) NOT NULL,
    error_class character varying(120) NOT NULL,
    message text NOT NULL,
    stacktrace_compressed bytea NOT NULL,
    stack_head text,
    request_path character varying(255),
    http_method character(6),
    status_code smallint DEFAULT 500 NOT NULL,
    params_json jsonb,
    user_id bigint,
    request_id character(36),
    ip_address inet,
    user_agent character varying(255),
    server_name character varying(60),
    environment character(10) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT h_error_logs_environment_check CHECK ((environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])))
);


--
-- Name: h_error_logs_202506; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_error_logs_202506 (
    id bigint DEFAULT nextval('public.h_error_logs_id_seq'::regclass) NOT NULL,
    error_class character varying(120) NOT NULL,
    message text NOT NULL,
    stacktrace_compressed bytea NOT NULL,
    stack_head text,
    request_path character varying(255),
    http_method character(6),
    status_code smallint DEFAULT 500 NOT NULL,
    params_json jsonb,
    user_id bigint,
    request_id character(36),
    ip_address inet,
    user_agent character varying(255),
    server_name character varying(60),
    environment character(10) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT h_error_logs_environment_check CHECK ((environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])))
);


--
-- Name: h_error_logs_202507; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_error_logs_202507 (
    id bigint DEFAULT nextval('public.h_error_logs_id_seq'::regclass) NOT NULL,
    error_class character varying(120) NOT NULL,
    message text NOT NULL,
    stacktrace_compressed bytea NOT NULL,
    stack_head text,
    request_path character varying(255),
    http_method character(6),
    status_code smallint DEFAULT 500 NOT NULL,
    params_json jsonb,
    user_id bigint,
    request_id character(36),
    ip_address inet,
    user_agent character varying(255),
    server_name character varying(60),
    environment character(10) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT h_error_logs_environment_check CHECK ((environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])))
);


--
-- Name: h_error_logs_202508; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_error_logs_202508 (
    id bigint DEFAULT nextval('public.h_error_logs_id_seq'::regclass) NOT NULL,
    error_class character varying(120) NOT NULL,
    message text NOT NULL,
    stacktrace_compressed bytea NOT NULL,
    stack_head text,
    request_path character varying(255),
    http_method character(6),
    status_code smallint DEFAULT 500 NOT NULL,
    params_json jsonb,
    user_id bigint,
    request_id character(36),
    ip_address inet,
    user_agent character varying(255),
    server_name character varying(60),
    environment character(10) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT h_error_logs_environment_check CHECK ((environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])))
);


--
-- Name: h_error_logs_202509; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_error_logs_202509 (
    id bigint DEFAULT nextval('public.h_error_logs_id_seq'::regclass) NOT NULL,
    error_class character varying(120) NOT NULL,
    message text NOT NULL,
    stacktrace_compressed bytea NOT NULL,
    stack_head text,
    request_path character varying(255),
    http_method character(6),
    status_code smallint DEFAULT 500 NOT NULL,
    params_json jsonb,
    user_id bigint,
    request_id character(36),
    ip_address inet,
    user_agent character varying(255),
    server_name character varying(60),
    environment character(10) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT h_error_logs_environment_check CHECK ((environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])))
);


--
-- Name: h_error_logs_202510; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_error_logs_202510 (
    id bigint DEFAULT nextval('public.h_error_logs_id_seq'::regclass) NOT NULL,
    error_class character varying(120) NOT NULL,
    message text NOT NULL,
    stacktrace_compressed bytea NOT NULL,
    stack_head text,
    request_path character varying(255),
    http_method character(6),
    status_code smallint DEFAULT 500 NOT NULL,
    params_json jsonb,
    user_id bigint,
    request_id character(36),
    ip_address inet,
    user_agent character varying(255),
    server_name character varying(60),
    environment character(10) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT h_error_logs_environment_check CHECK ((environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])))
);


--
-- Name: h_error_logs_202511; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_error_logs_202511 (
    id bigint DEFAULT nextval('public.h_error_logs_id_seq'::regclass) NOT NULL,
    error_class character varying(120) NOT NULL,
    message text NOT NULL,
    stacktrace_compressed bytea NOT NULL,
    stack_head text,
    request_path character varying(255),
    http_method character(6),
    status_code smallint DEFAULT 500 NOT NULL,
    params_json jsonb,
    user_id bigint,
    request_id character(36),
    ip_address inet,
    user_agent character varying(255),
    server_name character varying(60),
    environment character(10) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT h_error_logs_environment_check CHECK ((environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])))
);


--
-- Name: h_error_logs_202512; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_error_logs_202512 (
    id bigint DEFAULT nextval('public.h_error_logs_id_seq'::regclass) NOT NULL,
    error_class character varying(120) NOT NULL,
    message text NOT NULL,
    stacktrace_compressed bytea NOT NULL,
    stack_head text,
    request_path character varying(255),
    http_method character(6),
    status_code smallint DEFAULT 500 NOT NULL,
    params_json jsonb,
    user_id bigint,
    request_id character(36),
    ip_address inet,
    user_agent character varying(255),
    server_name character varying(60),
    environment character(10) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT h_error_logs_environment_check CHECK ((environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])))
);


--
-- Name: h_error_logs_202601; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_error_logs_202601 (
    id bigint DEFAULT nextval('public.h_error_logs_id_seq'::regclass) NOT NULL,
    error_class character varying(120) NOT NULL,
    message text NOT NULL,
    stacktrace_compressed bytea NOT NULL,
    stack_head text,
    request_path character varying(255),
    http_method character(6),
    status_code smallint DEFAULT 500 NOT NULL,
    params_json jsonb,
    user_id bigint,
    request_id character(36),
    ip_address inet,
    user_agent character varying(255),
    server_name character varying(60),
    environment character(10) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT h_error_logs_environment_check CHECK ((environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])))
);


--
-- Name: h_error_logs_202602; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_error_logs_202602 (
    id bigint DEFAULT nextval('public.h_error_logs_id_seq'::regclass) NOT NULL,
    error_class character varying(120) NOT NULL,
    message text NOT NULL,
    stacktrace_compressed bytea NOT NULL,
    stack_head text,
    request_path character varying(255),
    http_method character(6),
    status_code smallint DEFAULT 500 NOT NULL,
    params_json jsonb,
    user_id bigint,
    request_id character(36),
    ip_address inet,
    user_agent character varying(255),
    server_name character varying(60),
    environment character(10) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT h_error_logs_environment_check CHECK ((environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])))
);


--
-- Name: h_error_logs_202603; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_error_logs_202603 (
    id bigint DEFAULT nextval('public.h_error_logs_id_seq'::regclass) NOT NULL,
    error_class character varying(120) NOT NULL,
    message text NOT NULL,
    stacktrace_compressed bytea NOT NULL,
    stack_head text,
    request_path character varying(255),
    http_method character(6),
    status_code smallint DEFAULT 500 NOT NULL,
    params_json jsonb,
    user_id bigint,
    request_id character(36),
    ip_address inet,
    user_agent character varying(255),
    server_name character varying(60),
    environment character(10) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT h_error_logs_environment_check CHECK ((environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])))
);


--
-- Name: h_error_logs_202604; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_error_logs_202604 (
    id bigint DEFAULT nextval('public.h_error_logs_id_seq'::regclass) NOT NULL,
    error_class character varying(120) NOT NULL,
    message text NOT NULL,
    stacktrace_compressed bytea NOT NULL,
    stack_head text,
    request_path character varying(255),
    http_method character(6),
    status_code smallint DEFAULT 500 NOT NULL,
    params_json jsonb,
    user_id bigint,
    request_id character(36),
    ip_address inet,
    user_agent character varying(255),
    server_name character varying(60),
    environment character(10) NOT NULL,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT h_error_logs_environment_check CHECK ((environment = ANY (ARRAY['prod'::bpchar, 'stg'::bpchar, 'dev'::bpchar])))
);


--
-- Name: h_login_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_login_attempts (
    id bigint NOT NULL,
    user_id bigint,
    email_tried character varying(255) NOT NULL,
    ip_address inet NOT NULL,
    user_agent text NOT NULL,
    result smallint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_login_attempts_result_check CHECK ((result = ANY (ARRAY[0, 1, 2])))
)
PARTITION BY RANGE (created_at);


--
-- Name: h_login_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.h_login_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: h_login_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.h_login_attempts_id_seq OWNED BY public.h_login_attempts.id;


--
-- Name: h_login_attempts_202505; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_login_attempts_202505 (
    id bigint DEFAULT nextval('public.h_login_attempts_id_seq'::regclass) NOT NULL,
    user_id bigint,
    email_tried character varying(255) NOT NULL,
    ip_address inet NOT NULL,
    user_agent text NOT NULL,
    result smallint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_login_attempts_result_check CHECK ((result = ANY (ARRAY[0, 1, 2])))
);


--
-- Name: h_payment_webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payment_webhooks (
    id bigint NOT NULL,
    gateway character varying(30) NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    http_status smallint NOT NULL,
    signature character varying(255),
    payload_json jsonb NOT NULL,
    order_id bigint,
    payout_id bigint,
    processed_at timestamp with time zone,
    processing_result smallint,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_payment_webhooks_processing_result_check CHECK (((processing_result IS NULL) OR (processing_result = ANY (ARRAY[0, 1, 2]))))
)
PARTITION BY RANGE (created_at);


--
-- Name: h_payment_webhooks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.h_payment_webhooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: h_payment_webhooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.h_payment_webhooks_id_seq OWNED BY public.h_payment_webhooks.id;


--
-- Name: h_payment_webhooks_202505; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payment_webhooks_202505 (
    id bigint DEFAULT nextval('public.h_payment_webhooks_id_seq'::regclass) NOT NULL,
    gateway character varying(30) NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    http_status smallint NOT NULL,
    signature character varying(255),
    payload_json jsonb NOT NULL,
    order_id bigint,
    payout_id bigint,
    processed_at timestamp with time zone,
    processing_result smallint,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_payment_webhooks_processing_result_check CHECK (((processing_result IS NULL) OR (processing_result = ANY (ARRAY[0, 1, 2]))))
);


--
-- Name: h_payment_webhooks_202506; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payment_webhooks_202506 (
    id bigint DEFAULT nextval('public.h_payment_webhooks_id_seq'::regclass) NOT NULL,
    gateway character varying(30) NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    http_status smallint NOT NULL,
    signature character varying(255),
    payload_json jsonb NOT NULL,
    order_id bigint,
    payout_id bigint,
    processed_at timestamp with time zone,
    processing_result smallint,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_payment_webhooks_processing_result_check CHECK (((processing_result IS NULL) OR (processing_result = ANY (ARRAY[0, 1, 2]))))
);


--
-- Name: h_payment_webhooks_202507; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payment_webhooks_202507 (
    id bigint DEFAULT nextval('public.h_payment_webhooks_id_seq'::regclass) NOT NULL,
    gateway character varying(30) NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    http_status smallint NOT NULL,
    signature character varying(255),
    payload_json jsonb NOT NULL,
    order_id bigint,
    payout_id bigint,
    processed_at timestamp with time zone,
    processing_result smallint,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_payment_webhooks_processing_result_check CHECK (((processing_result IS NULL) OR (processing_result = ANY (ARRAY[0, 1, 2]))))
);


--
-- Name: h_payment_webhooks_202508; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payment_webhooks_202508 (
    id bigint DEFAULT nextval('public.h_payment_webhooks_id_seq'::regclass) NOT NULL,
    gateway character varying(30) NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    http_status smallint NOT NULL,
    signature character varying(255),
    payload_json jsonb NOT NULL,
    order_id bigint,
    payout_id bigint,
    processed_at timestamp with time zone,
    processing_result smallint,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_payment_webhooks_processing_result_check CHECK (((processing_result IS NULL) OR (processing_result = ANY (ARRAY[0, 1, 2]))))
);


--
-- Name: h_payment_webhooks_202509; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payment_webhooks_202509 (
    id bigint DEFAULT nextval('public.h_payment_webhooks_id_seq'::regclass) NOT NULL,
    gateway character varying(30) NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    http_status smallint NOT NULL,
    signature character varying(255),
    payload_json jsonb NOT NULL,
    order_id bigint,
    payout_id bigint,
    processed_at timestamp with time zone,
    processing_result smallint,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_payment_webhooks_processing_result_check CHECK (((processing_result IS NULL) OR (processing_result = ANY (ARRAY[0, 1, 2]))))
);


--
-- Name: h_payment_webhooks_202510; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payment_webhooks_202510 (
    id bigint DEFAULT nextval('public.h_payment_webhooks_id_seq'::regclass) NOT NULL,
    gateway character varying(30) NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    http_status smallint NOT NULL,
    signature character varying(255),
    payload_json jsonb NOT NULL,
    order_id bigint,
    payout_id bigint,
    processed_at timestamp with time zone,
    processing_result smallint,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_payment_webhooks_processing_result_check CHECK (((processing_result IS NULL) OR (processing_result = ANY (ARRAY[0, 1, 2]))))
);


--
-- Name: h_payment_webhooks_202511; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payment_webhooks_202511 (
    id bigint DEFAULT nextval('public.h_payment_webhooks_id_seq'::regclass) NOT NULL,
    gateway character varying(30) NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    http_status smallint NOT NULL,
    signature character varying(255),
    payload_json jsonb NOT NULL,
    order_id bigint,
    payout_id bigint,
    processed_at timestamp with time zone,
    processing_result smallint,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_payment_webhooks_processing_result_check CHECK (((processing_result IS NULL) OR (processing_result = ANY (ARRAY[0, 1, 2]))))
);


--
-- Name: h_payment_webhooks_202512; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payment_webhooks_202512 (
    id bigint DEFAULT nextval('public.h_payment_webhooks_id_seq'::regclass) NOT NULL,
    gateway character varying(30) NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    http_status smallint NOT NULL,
    signature character varying(255),
    payload_json jsonb NOT NULL,
    order_id bigint,
    payout_id bigint,
    processed_at timestamp with time zone,
    processing_result smallint,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_payment_webhooks_processing_result_check CHECK (((processing_result IS NULL) OR (processing_result = ANY (ARRAY[0, 1, 2]))))
);


--
-- Name: h_payment_webhooks_202601; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payment_webhooks_202601 (
    id bigint DEFAULT nextval('public.h_payment_webhooks_id_seq'::regclass) NOT NULL,
    gateway character varying(30) NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    http_status smallint NOT NULL,
    signature character varying(255),
    payload_json jsonb NOT NULL,
    order_id bigint,
    payout_id bigint,
    processed_at timestamp with time zone,
    processing_result smallint,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_payment_webhooks_processing_result_check CHECK (((processing_result IS NULL) OR (processing_result = ANY (ARRAY[0, 1, 2]))))
);


--
-- Name: h_payment_webhooks_202602; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payment_webhooks_202602 (
    id bigint DEFAULT nextval('public.h_payment_webhooks_id_seq'::regclass) NOT NULL,
    gateway character varying(30) NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    http_status smallint NOT NULL,
    signature character varying(255),
    payload_json jsonb NOT NULL,
    order_id bigint,
    payout_id bigint,
    processed_at timestamp with time zone,
    processing_result smallint,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_payment_webhooks_processing_result_check CHECK (((processing_result IS NULL) OR (processing_result = ANY (ARRAY[0, 1, 2]))))
);


--
-- Name: h_payment_webhooks_202603; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payment_webhooks_202603 (
    id bigint DEFAULT nextval('public.h_payment_webhooks_id_seq'::regclass) NOT NULL,
    gateway character varying(30) NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    http_status smallint NOT NULL,
    signature character varying(255),
    payload_json jsonb NOT NULL,
    order_id bigint,
    payout_id bigint,
    processed_at timestamp with time zone,
    processing_result smallint,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_payment_webhooks_processing_result_check CHECK (((processing_result IS NULL) OR (processing_result = ANY (ARRAY[0, 1, 2]))))
);


--
-- Name: h_payment_webhooks_202604; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payment_webhooks_202604 (
    id bigint DEFAULT nextval('public.h_payment_webhooks_id_seq'::regclass) NOT NULL,
    gateway character varying(30) NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    http_status smallint NOT NULL,
    signature character varying(255),
    payload_json jsonb NOT NULL,
    order_id bigint,
    payout_id bigint,
    processed_at timestamp with time zone,
    processing_result smallint,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT h_payment_webhooks_processing_result_check CHECK (((processing_result IS NULL) OR (processing_result = ANY (ARRAY[0, 1, 2]))))
);


--
-- Name: h_payout_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.h_payout_events (
    id bigint NOT NULL,
    payout_id bigint NOT NULL,
    event character varying(30) NOT NULL,
    meta_json jsonb,
    occurred_at timestamp(6) without time zone NOT NULL,
    logged_by_type character varying(20),
    logged_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_hpe_logged_by_type CHECK ((((logged_by_type)::text = ANY ((ARRAY['System'::character varying, 'User'::character varying, 'Admin'::character varying])::text[])) OR (logged_by_type IS NULL)))
);


--
-- Name: h_payout_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.h_payout_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: h_payout_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.h_payout_events_id_seq OWNED BY public.h_payout_events.id;


--
-- Name: m_authorities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_authorities (
    code character varying(30) NOT NULL,
    name_ja character varying(60) NOT NULL,
    default_roles jsonb,
    active_flag boolean DEFAULT true NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: m_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_categories (
    code character varying(10) NOT NULL,
    name_ja character varying(20) NOT NULL,
    name_en character varying(20) NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: m_cities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_cities (
    code character varying(5) NOT NULL,
    prefecture_code character varying(2) NOT NULL,
    name_ja character varying(100) NOT NULL,
    name_kana character varying(100),
    name_en character varying(100),
    sort_no smallint,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT m_cities_code_len_chk CHECK ((char_length((code)::text) = 5))
);


--
-- Name: m_corner_processes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_corner_processes (
    code character varying(10) NOT NULL,
    name_ja character varying(30) NOT NULL,
    name_en character varying(30) NOT NULL,
    description_ja character varying(80),
    description_en character varying(80),
    allow_corner_proc_json text[] DEFAULT '{}'::text[] NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: m_edge_processes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_edge_processes (
    code character varying(10) NOT NULL,
    name_ja character varying(20) NOT NULL,
    name_en character varying(10) NOT NULL,
    description_ja character varying(80),
    description_en character varying(80),
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: m_glosses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_glosses (
    code character varying(6) NOT NULL,
    name_ja character varying(30) NOT NULL,
    name_en character varying(30) NOT NULL,
    gloss_pct smallint NOT NULL,
    description_ja character varying(80),
    description_en character varying(80),
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_gloss_pct CHECK (((gloss_pct >= 0) AND (gloss_pct <= 100)))
);


--
-- Name: m_grain_finishes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_grain_finishes (
    code character varying(6) NOT NULL,
    name_ja character varying(30) NOT NULL,
    name_en character varying(30) NOT NULL,
    description_ja character varying(80),
    description_en character varying(80),
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: m_hole_diameters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_hole_diameters (
    code character varying(10) NOT NULL,
    hole_mm numeric(8,2) NOT NULL,
    name_ja character varying(20) NOT NULL,
    name_en character varying(6) NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: m_materials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_materials (
    code character varying(16) NOT NULL,
    category_code character varying(10) NOT NULL,
    name_ja character varying(40) NOT NULL,
    name_en character varying(40) NOT NULL,
    description_ja character varying(80),
    description_en character varying(80),
    jis_iso character varying(12),
    density_kg_per_m3 numeric(8,2) NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: m_paint_colors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_paint_colors (
    code character varying(6) NOT NULL,
    name_ja character varying(30) NOT NULL,
    name_en character varying(30) NOT NULL,
    description_ja character varying(80),
    description_en character varying(80),
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: m_paint_surfaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_paint_surfaces (
    code character varying(6) NOT NULL,
    name_ja character varying(30) NOT NULL,
    name_en character varying(30) NOT NULL,
    description_ja character varying(80),
    description_en character varying(80),
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: m_paint_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_paint_types (
    code character varying(10) NOT NULL,
    name_ja character varying(30) NOT NULL,
    name_en character varying(30) NOT NULL,
    description_ja character varying(80),
    description_en character varying(80),
    allow_paint_json text[] DEFAULT '{}'::text[] NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: m_postal_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_postal_codes (
    id bigint NOT NULL,
    postal_code character varying(7) NOT NULL,
    city_code character varying(5) NOT NULL,
    city_town_name_kanji text NOT NULL,
    town_area_name_kanji text,
    multi_town_flag boolean DEFAULT false NOT NULL,
    koaza_banchi_flag boolean DEFAULT false NOT NULL,
    chome_flag boolean DEFAULT false NOT NULL,
    multi_aza_flag boolean DEFAULT false NOT NULL,
    deleted_flag boolean DEFAULT false NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT postal_city_len_chk CHECK ((char_length((city_code)::text) = 5)),
    CONSTRAINT postal_code_len_chk CHECK ((char_length((postal_code)::text) = 7))
);


--
-- Name: m_postal_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.m_postal_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: m_postal_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.m_postal_codes_id_seq OWNED BY public.m_postal_codes.id;


--
-- Name: m_prefectures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_prefectures (
    code character varying(2) NOT NULL,
    name_ja character varying(10) NOT NULL,
    name_en character varying(20) NOT NULL,
    kana character varying(20) NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT m_prefectures_code_chk CHECK ((((code)::text >= '01'::text) AND ((code)::text <= '47'::text)))
);


--
-- Name: m_process_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_process_types (
    code character varying(10) NOT NULL,
    category_code character varying(10) NOT NULL,
    name_ja character varying(40) NOT NULL,
    name_en character varying(40) NOT NULL,
    description_ja character varying(80),
    description_en character varying(80),
    jis_iso character varying(12),
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: m_shapes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.m_shapes (
    code character varying(10) NOT NULL,
    name_ja character varying(30) NOT NULL,
    name_en character varying(30) NOT NULL,
    description_ja character varying(80),
    description_en character varying(80),
    allow_shape_json text[] DEFAULT '{}'::text[] NOT NULL,
    allow_corner_json text[] DEFAULT '{}'::text[] NOT NULL,
    allow_edge_json text[] DEFAULT '{}'::text[] NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: member_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.member_details (
    user_id bigint NOT NULL,
    nickname character varying(50),
    icon_url character varying,
    legal_type smallint NOT NULL,
    legal_name character varying NOT NULL,
    legal_name_kana character varying,
    birthday date,
    gender character varying(1),
    billing_postal_code character varying(20),
    billing_prefecture_code character varying(2),
    billing_city_code character varying(5) NOT NULL,
    billing_address_line character varying(200) NOT NULL,
    billing_department character varying(100),
    billing_phone_number character varying(30),
    primary_shipping_id bigint,
    stripe_customer_id character varying,
    registered_affiliate_id bigint,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    membership_plan integer DEFAULT 0 NOT NULL
);


--
-- Name: member_shipping_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.member_shipping_addresses (
    id bigint NOT NULL,
    member_id bigint NOT NULL,
    label character varying(50),
    recipient_name character varying(100) NOT NULL,
    postal_code character varying(8) NOT NULL,
    prefecture_code character varying(2) NOT NULL,
    city_code character varying(5) NOT NULL,
    address_line character varying(200) NOT NULL,
    phone_number character varying(20),
    is_default boolean DEFAULT false NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: member_shipping_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.member_shipping_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: member_shipping_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.member_shipping_addresses_id_seq OWNED BY public.member_shipping_addresses.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    recipient_type character varying NOT NULL,
    recipient_id bigint NOT NULL,
    channel smallint NOT NULL,
    notification_type character varying(30) NOT NULL,
    subject character varying(150),
    body text,
    payload_json jsonb,
    related_model_type character varying(30),
    related_model_id bigint,
    status smallint DEFAULT 0 NOT NULL,
    broadcast_id uuid DEFAULT gen_random_uuid(),
    sent_at timestamp(6) without time zone,
    read_at timestamp(6) without time zone,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_notifications_recipient_type CHECK (((recipient_type)::text = ANY ((ARRAY['MemberDetail'::character varying, 'VendorDetail'::character varying, 'AdminDetail'::character varying, 'AffiliateDetail'::character varying])::text[])))
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: order_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_reviews (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    reviewer_id bigint NOT NULL,
    vendor_id bigint NOT NULL,
    rating jsonb NOT NULL,
    title character varying(100),
    comment text,
    vendor_reply text,
    replied_at timestamp(6) without time zone,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: order_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_reviews_id_seq OWNED BY public.order_reviews.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id bigint NOT NULL,
    quote_id bigint NOT NULL,
    quote_request_id bigint,
    user_id bigint NOT NULL,
    vendor_id bigint NOT NULL,
    affiliate_id bigint,
    status smallint DEFAULT 0 NOT NULL,
    total_amount numeric(18,4) DEFAULT 0.0 NOT NULL,
    shipping_address_id bigint NOT NULL,
    shipping_method smallint DEFAULT 0 NOT NULL,
    shipping_size_class smallint,
    paid_at timestamp(6) without time zone,
    shipped_at timestamp(6) without time zone,
    delivered_at timestamp(6) without time zone,
    shipping_tracking_no character varying(50),
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: payouts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payouts (
    id bigint NOT NULL,
    payee_type character varying(20) NOT NULL,
    payee_id bigint NOT NULL,
    period_from date,
    period_to date,
    gross_amount numeric(18,4) DEFAULT 0.0 NOT NULL,
    commission_amount numeric(18,4) DEFAULT 0.0 NOT NULL,
    net_amount numeric(18,4) DEFAULT 0.0 NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    payout_at timestamp(6) without time zone,
    transaction_ref character varying(100),
    bank_name character varying(100),
    account_type smallint,
    account_number character varying(30),
    remarks text,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_payouts_payee_type CHECK (((payee_type)::text = ANY ((ARRAY['MemberDetail'::character varying, 'VendorDetail'::character varying, 'AdminDetail'::character varying, 'AffiliateDetail'::character varying])::text[])))
);


--
-- Name: payouts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payouts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payouts_id_seq OWNED BY public.payouts.id;


--
-- Name: quote_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quote_items (
    id bigint NOT NULL,
    quote_id bigint NOT NULL,
    line_no smallint NOT NULL,
    material_category_code character varying(10) NOT NULL,
    material_code character varying(16) NOT NULL,
    shape_code character varying(10) NOT NULL,
    paint_type_code character varying(10),
    thickness_mm numeric(8,2) NOT NULL,
    width1_mm numeric(8,2) NOT NULL,
    width2_mm numeric(8,2),
    length_mm numeric(8,2) NOT NULL,
    shape_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    corner_proc_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    hole_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    sqhole_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    edge_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    paint_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    quantity integer NOT NULL,
    shipping_size_class smallint,
    note text,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_positive_dims CHECK (((thickness_mm > (0)::numeric) AND (width1_mm > (0)::numeric) AND (length_mm > (0)::numeric) AND ((width2_mm IS NULL) OR (width2_mm > (0)::numeric)) AND (quantity > 0)))
);


--
-- Name: quote_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quote_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quote_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quote_items_id_seq OWNED BY public.quote_items.id;


--
-- Name: quote_request_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quote_request_comments (
    id bigint NOT NULL,
    quote_request_id bigint NOT NULL,
    parent_id bigint,
    author_type character varying(20) NOT NULL,
    author_id bigint NOT NULL,
    body text NOT NULL,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_qr_comments_author_type CHECK (((author_type)::text = ANY ((ARRAY['MemberDetail'::character varying, 'VendorDetail'::character varying, 'AdminDetail'::character varying, 'AffiliateDetail'::character varying])::text[])))
);


--
-- Name: quote_request_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quote_request_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quote_request_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quote_request_comments_id_seq OWNED BY public.quote_request_comments.id;


--
-- Name: quote_request_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quote_request_items (
    id bigint NOT NULL,
    quote_request_id bigint NOT NULL,
    quote_item_id bigint NOT NULL,
    unit_price numeric(18,4) DEFAULT 0.0 NOT NULL,
    amount numeric(18,4) DEFAULT 0.0 NOT NULL,
    memo text,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_amount_non_negative CHECK ((amount >= (0)::numeric))
);


--
-- Name: quote_request_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quote_request_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quote_request_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quote_request_items_id_seq OWNED BY public.quote_request_items.id;


--
-- Name: quote_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quote_requests (
    id bigint NOT NULL,
    quote_id bigint NOT NULL,
    vendor_id bigint NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    items_subtotal numeric(18,4) DEFAULT 0.0 NOT NULL,
    shipping_fee numeric(18,4) DEFAULT 0.0 NOT NULL,
    tax_rate_pct numeric(4,2) DEFAULT 10.0 NOT NULL,
    tax_amount numeric(18,4) DEFAULT 0.0 NOT NULL,
    total_estimate numeric(18,4) DEFAULT 0.0 NOT NULL,
    answered_at timestamp(6) without time zone,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: quote_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quote_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quote_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quote_requests_id_seq OWNED BY public.quote_requests.id;


--
-- Name: quotes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quotes (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    shipping_address_id bigint NOT NULL,
    ship_prefecture_code character varying(2) DEFAULT ''::character varying NOT NULL,
    ship_city_code character varying(5),
    global_requirements text,
    deadline date,
    remarks text,
    accepted_request_id bigint,
    accepted_at timestamp(6) without time zone,
    total_estimate numeric(18,4) DEFAULT 0.0 NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: quotes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quotes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quotes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quotes_id_seq OWNED BY public.quotes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: stripe_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_accounts (
    user_id bigint NOT NULL,
    stripe_account_id character varying(255) NOT NULL,
    charges_enabled boolean DEFAULT false NOT NULL,
    payouts_enabled boolean DEFAULT false NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: stripe_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_events (
    event_id character varying(255) NOT NULL,
    account_id character varying(255) NOT NULL,
    type character varying(64) NOT NULL,
    payload jsonb NOT NULL,
    received_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    processed_at timestamp(6) without time zone,
    status character varying(16)
);


--
-- Name: stripe_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_payments (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    payment_intent_id character varying(255) NOT NULL,
    charge_id character varying(255) NOT NULL,
    transfer_id character varying(255) NOT NULL,
    application_fee_id character varying(255) NOT NULL,
    amount numeric(18,4) DEFAULT 0.0 NOT NULL,
    currency character varying(3) DEFAULT 'JPY'::character varying NOT NULL,
    platform_fee numeric(18,4) DEFAULT 0.0 NOT NULL,
    net_amount numeric(18,4) DEFAULT 0.0 NOT NULL,
    status character varying(32) NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: stripe_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stripe_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stripe_payments_id_seq OWNED BY public.stripe_payments.id;


--
-- Name: stripe_payouts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_payouts (
    payout_id character varying NOT NULL,
    stripe_account_id character varying(255) NOT NULL,
    amount numeric(18,4) DEFAULT 0.0 NOT NULL,
    arrival_date date NOT NULL,
    status character varying(16) NOT NULL,
    failure_code character varying(32),
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: stripe_refunds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_refunds (
    refund_id character varying(255) NOT NULL,
    payment_intent_id character varying(255) NOT NULL,
    amount numeric(18,4) DEFAULT 0.0 NOT NULL,
    status character varying(16) NOT NULL,
    reason character varying(32) NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: user_authorities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_authorities (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    authority_code character varying(30) NOT NULL,
    grant_state smallint DEFAULT 1 NOT NULL,
    valid_from timestamp(6) without time zone,
    valid_to timestamp(6) without time zone,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT user_authorities_grant_state_chk CHECK ((grant_state = ANY (ARRAY[0, 1])))
);


--
-- Name: user_authorities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_authorities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_authorities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_authorities_id_seq OWNED BY public.user_authorities.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    public_uid character varying(32) NOT NULL,
    email character varying NOT NULL,
    encrypted_password character varying NOT NULL,
    role smallint NOT NULL,
    password_changed_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    password_expires_at timestamp(6) without time zone,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp(6) without time zone,
    last_sign_in_at timestamp(6) without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp(6) without time zone,
    CONSTRAINT users_role_value CHECK ((role = ANY (ARRAY[0, 1, 2, 3])))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vendor_capabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendor_capabilities (
    vendor_id bigint NOT NULL,
    capability_code character varying(16) NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: vendor_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendor_details (
    user_id bigint NOT NULL,
    nickname character varying(50),
    profile_icon_url character varying(500),
    vendor_name character varying(100) NOT NULL,
    vendor_name_kana character varying(100),
    invoice_number character varying(20),
    contact_person_name character varying(80) NOT NULL,
    contact_person_kana character varying(80),
    contact_phone_number character varying(20),
    office_postal_code character varying(8),
    office_prefecture_code character varying(2) NOT NULL,
    office_city_code character varying(5) NOT NULL,
    office_address_line character varying(200) NOT NULL,
    office_phone_number character varying(20),
    bank_name character varying(60),
    account_type smallint,
    account_number character varying(20),
    account_name character varying(100),
    shipping_base_address_json jsonb,
    notes text,
    stripe_account_id character varying(255) NOT NULL,
    charges_enabled boolean DEFAULT false NOT NULL,
    payouts_enabled boolean DEFAULT false NOT NULL,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: vendor_materials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendor_materials (
    vendor_id bigint NOT NULL,
    material_code character varying(16) NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: vendor_service_areas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendor_service_areas (
    vendor_id bigint NOT NULL,
    prefecture_code character varying(2) NOT NULL,
    city_code character varying(5) NOT NULL,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: h_article_views_202505; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_article_views ATTACH PARTITION public.h_article_views_202505 FOR VALUES FROM ('2025-05-01 00:00:00+00') TO ('2025-06-01 00:00:00+00');


--
-- Name: h_article_views_202506; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_article_views ATTACH PARTITION public.h_article_views_202506 FOR VALUES FROM ('2025-06-01 00:00:00+00') TO ('2025-07-01 00:00:00+00');


--
-- Name: h_article_views_202507; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_article_views ATTACH PARTITION public.h_article_views_202507 FOR VALUES FROM ('2025-07-01 00:00:00+00') TO ('2025-08-01 00:00:00+00');


--
-- Name: h_article_views_202508; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_article_views ATTACH PARTITION public.h_article_views_202508 FOR VALUES FROM ('2025-08-01 00:00:00+00') TO ('2025-09-01 00:00:00+00');


--
-- Name: h_article_views_202509; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_article_views ATTACH PARTITION public.h_article_views_202509 FOR VALUES FROM ('2025-09-01 00:00:00+00') TO ('2025-10-01 00:00:00+00');


--
-- Name: h_article_views_202510; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_article_views ATTACH PARTITION public.h_article_views_202510 FOR VALUES FROM ('2025-10-01 00:00:00+00') TO ('2025-11-01 00:00:00+00');


--
-- Name: h_article_views_202511; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_article_views ATTACH PARTITION public.h_article_views_202511 FOR VALUES FROM ('2025-11-01 00:00:00+00') TO ('2025-12-01 00:00:00+00');


--
-- Name: h_article_views_202512; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_article_views ATTACH PARTITION public.h_article_views_202512 FOR VALUES FROM ('2025-12-01 00:00:00+00') TO ('2026-01-01 00:00:00+00');


--
-- Name: h_article_views_202601; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_article_views ATTACH PARTITION public.h_article_views_202601 FOR VALUES FROM ('2026-01-01 00:00:00+00') TO ('2026-02-01 00:00:00+00');


--
-- Name: h_article_views_202602; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_article_views ATTACH PARTITION public.h_article_views_202602 FOR VALUES FROM ('2026-02-01 00:00:00+00') TO ('2026-03-01 00:00:00+00');


--
-- Name: h_article_views_202603; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_article_views ATTACH PARTITION public.h_article_views_202603 FOR VALUES FROM ('2026-03-01 00:00:00+00') TO ('2026-04-01 00:00:00+00');


--
-- Name: h_article_views_202604; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_article_views ATTACH PARTITION public.h_article_views_202604 FOR VALUES FROM ('2026-04-01 00:00:00+00') TO ('2026-05-01 00:00:00+00');


--
-- Name: h_audit_trails_202505; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_audit_trails ATTACH PARTITION public.h_audit_trails_202505 FOR VALUES FROM ('2025-05-01 00:00:00+00') TO ('2025-06-01 00:00:00+00');


--
-- Name: h_error_logs_202505; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_error_logs ATTACH PARTITION public.h_error_logs_202505 FOR VALUES FROM ('2025-05-01 00:00:00+00') TO ('2025-06-01 00:00:00+00');


--
-- Name: h_error_logs_202506; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_error_logs ATTACH PARTITION public.h_error_logs_202506 FOR VALUES FROM ('2025-06-01 00:00:00+00') TO ('2025-07-01 00:00:00+00');


--
-- Name: h_error_logs_202507; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_error_logs ATTACH PARTITION public.h_error_logs_202507 FOR VALUES FROM ('2025-07-01 00:00:00+00') TO ('2025-08-01 00:00:00+00');


--
-- Name: h_error_logs_202508; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_error_logs ATTACH PARTITION public.h_error_logs_202508 FOR VALUES FROM ('2025-08-01 00:00:00+00') TO ('2025-09-01 00:00:00+00');


--
-- Name: h_error_logs_202509; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_error_logs ATTACH PARTITION public.h_error_logs_202509 FOR VALUES FROM ('2025-09-01 00:00:00+00') TO ('2025-10-01 00:00:00+00');


--
-- Name: h_error_logs_202510; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_error_logs ATTACH PARTITION public.h_error_logs_202510 FOR VALUES FROM ('2025-10-01 00:00:00+00') TO ('2025-11-01 00:00:00+00');


--
-- Name: h_error_logs_202511; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_error_logs ATTACH PARTITION public.h_error_logs_202511 FOR VALUES FROM ('2025-11-01 00:00:00+00') TO ('2025-12-01 00:00:00+00');


--
-- Name: h_error_logs_202512; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_error_logs ATTACH PARTITION public.h_error_logs_202512 FOR VALUES FROM ('2025-12-01 00:00:00+00') TO ('2026-01-01 00:00:00+00');


--
-- Name: h_error_logs_202601; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_error_logs ATTACH PARTITION public.h_error_logs_202601 FOR VALUES FROM ('2026-01-01 00:00:00+00') TO ('2026-02-01 00:00:00+00');


--
-- Name: h_error_logs_202602; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_error_logs ATTACH PARTITION public.h_error_logs_202602 FOR VALUES FROM ('2026-02-01 00:00:00+00') TO ('2026-03-01 00:00:00+00');


--
-- Name: h_error_logs_202603; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_error_logs ATTACH PARTITION public.h_error_logs_202603 FOR VALUES FROM ('2026-03-01 00:00:00+00') TO ('2026-04-01 00:00:00+00');


--
-- Name: h_error_logs_202604; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_error_logs ATTACH PARTITION public.h_error_logs_202604 FOR VALUES FROM ('2026-04-01 00:00:00+00') TO ('2026-05-01 00:00:00+00');


--
-- Name: h_login_attempts_202505; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_login_attempts ATTACH PARTITION public.h_login_attempts_202505 FOR VALUES FROM ('2025-05-01 00:00:00+00') TO ('2025-06-01 00:00:00+00');


--
-- Name: h_payment_webhooks_202505; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payment_webhooks ATTACH PARTITION public.h_payment_webhooks_202505 FOR VALUES FROM ('2025-05-01 00:00:00+00') TO ('2025-06-01 00:00:00+00');


--
-- Name: h_payment_webhooks_202506; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payment_webhooks ATTACH PARTITION public.h_payment_webhooks_202506 FOR VALUES FROM ('2025-06-01 00:00:00+00') TO ('2025-07-01 00:00:00+00');


--
-- Name: h_payment_webhooks_202507; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payment_webhooks ATTACH PARTITION public.h_payment_webhooks_202507 FOR VALUES FROM ('2025-07-01 00:00:00+00') TO ('2025-08-01 00:00:00+00');


--
-- Name: h_payment_webhooks_202508; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payment_webhooks ATTACH PARTITION public.h_payment_webhooks_202508 FOR VALUES FROM ('2025-08-01 00:00:00+00') TO ('2025-09-01 00:00:00+00');


--
-- Name: h_payment_webhooks_202509; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payment_webhooks ATTACH PARTITION public.h_payment_webhooks_202509 FOR VALUES FROM ('2025-09-01 00:00:00+00') TO ('2025-10-01 00:00:00+00');


--
-- Name: h_payment_webhooks_202510; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payment_webhooks ATTACH PARTITION public.h_payment_webhooks_202510 FOR VALUES FROM ('2025-10-01 00:00:00+00') TO ('2025-11-01 00:00:00+00');


--
-- Name: h_payment_webhooks_202511; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payment_webhooks ATTACH PARTITION public.h_payment_webhooks_202511 FOR VALUES FROM ('2025-11-01 00:00:00+00') TO ('2025-12-01 00:00:00+00');


--
-- Name: h_payment_webhooks_202512; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payment_webhooks ATTACH PARTITION public.h_payment_webhooks_202512 FOR VALUES FROM ('2025-12-01 00:00:00+00') TO ('2026-01-01 00:00:00+00');


--
-- Name: h_payment_webhooks_202601; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payment_webhooks ATTACH PARTITION public.h_payment_webhooks_202601 FOR VALUES FROM ('2026-01-01 00:00:00+00') TO ('2026-02-01 00:00:00+00');


--
-- Name: h_payment_webhooks_202602; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payment_webhooks ATTACH PARTITION public.h_payment_webhooks_202602 FOR VALUES FROM ('2026-02-01 00:00:00+00') TO ('2026-03-01 00:00:00+00');


--
-- Name: h_payment_webhooks_202603; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payment_webhooks ATTACH PARTITION public.h_payment_webhooks_202603 FOR VALUES FROM ('2026-03-01 00:00:00+00') TO ('2026-04-01 00:00:00+00');


--
-- Name: h_payment_webhooks_202604; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payment_webhooks ATTACH PARTITION public.h_payment_webhooks_202604 FOR VALUES FROM ('2026-04-01 00:00:00+00') TO ('2026-05-01 00:00:00+00');


--
-- Name: affiliate_commissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_commissions ALTER COLUMN id SET DEFAULT nextval('public.affiliate_commissions_id_seq'::regclass);


--
-- Name: affiliate_signups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_signups ALTER COLUMN id SET DEFAULT nextval('public.affiliate_signups_id_seq'::regclass);


--
-- Name: article_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_comments ALTER COLUMN id SET DEFAULT nextval('public.article_comments_id_seq'::regclass);


--
-- Name: article_likes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_likes ALTER COLUMN id SET DEFAULT nextval('public.article_likes_id_seq'::regclass);


--
-- Name: article_media id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_media ALTER COLUMN id SET DEFAULT nextval('public.article_media_id_seq'::regclass);


--
-- Name: articles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articles ALTER COLUMN id SET DEFAULT nextval('public.articles_id_seq'::regclass);


--
-- Name: h_affiliate_clicks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_affiliate_clicks ALTER COLUMN id SET DEFAULT nextval('public.h_affiliate_clicks_id_seq'::regclass);


--
-- Name: h_article_views id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_article_views ALTER COLUMN id SET DEFAULT nextval('public.h_article_views_id_seq'::regclass);


--
-- Name: h_audit_trails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_audit_trails ALTER COLUMN id SET DEFAULT nextval('public.h_audit_trails_id_seq'::regclass);


--
-- Name: h_error_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_error_logs ALTER COLUMN id SET DEFAULT nextval('public.h_error_logs_id_seq'::regclass);


--
-- Name: h_login_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_login_attempts ALTER COLUMN id SET DEFAULT nextval('public.h_login_attempts_id_seq'::regclass);


--
-- Name: h_payment_webhooks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payment_webhooks ALTER COLUMN id SET DEFAULT nextval('public.h_payment_webhooks_id_seq'::regclass);


--
-- Name: h_payout_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payout_events ALTER COLUMN id SET DEFAULT nextval('public.h_payout_events_id_seq'::regclass);


--
-- Name: m_postal_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_postal_codes ALTER COLUMN id SET DEFAULT nextval('public.m_postal_codes_id_seq'::regclass);


--
-- Name: member_shipping_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_shipping_addresses ALTER COLUMN id SET DEFAULT nextval('public.member_shipping_addresses_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: order_reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_reviews ALTER COLUMN id SET DEFAULT nextval('public.order_reviews_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: payouts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payouts ALTER COLUMN id SET DEFAULT nextval('public.payouts_id_seq'::regclass);


--
-- Name: quote_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_items ALTER COLUMN id SET DEFAULT nextval('public.quote_items_id_seq'::regclass);


--
-- Name: quote_request_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_comments ALTER COLUMN id SET DEFAULT nextval('public.quote_request_comments_id_seq'::regclass);


--
-- Name: quote_request_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_items ALTER COLUMN id SET DEFAULT nextval('public.quote_request_items_id_seq'::regclass);


--
-- Name: quote_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_requests ALTER COLUMN id SET DEFAULT nextval('public.quote_requests_id_seq'::regclass);


--
-- Name: quotes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotes ALTER COLUMN id SET DEFAULT nextval('public.quotes_id_seq'::regclass);


--
-- Name: stripe_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_payments ALTER COLUMN id SET DEFAULT nextval('public.stripe_payments_id_seq'::regclass);


--
-- Name: user_authorities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_authorities ALTER COLUMN id SET DEFAULT nextval('public.user_authorities_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: admin_details admin_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_details
    ADD CONSTRAINT admin_details_pkey PRIMARY KEY (user_id);


--
-- Name: affiliate_commissions affiliate_commissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_commissions
    ADD CONSTRAINT affiliate_commissions_pkey PRIMARY KEY (id);


--
-- Name: affiliate_details affiliate_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_details
    ADD CONSTRAINT affiliate_details_pkey PRIMARY KEY (user_id);


--
-- Name: affiliate_signups affiliate_signups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_signups
    ADD CONSTRAINT affiliate_signups_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: article_comments article_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_comments
    ADD CONSTRAINT article_comments_pkey PRIMARY KEY (id);


--
-- Name: article_likes article_likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_likes
    ADD CONSTRAINT article_likes_pkey PRIMARY KEY (id);


--
-- Name: article_media article_media_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_media
    ADD CONSTRAINT article_media_pkey PRIMARY KEY (id);


--
-- Name: articles articles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_pkey PRIMARY KEY (id);


--
-- Name: h_affiliate_clicks h_affiliate_clicks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_affiliate_clicks
    ADD CONSTRAINT h_affiliate_clicks_pkey PRIMARY KEY (id);


--
-- Name: h_payout_events h_payout_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payout_events
    ADD CONSTRAINT h_payout_events_pkey PRIMARY KEY (id);


--
-- Name: m_categories m_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_categories
    ADD CONSTRAINT m_categories_pkey PRIMARY KEY (code);


--
-- Name: m_corner_processes m_corner_processes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_corner_processes
    ADD CONSTRAINT m_corner_processes_pkey PRIMARY KEY (code);


--
-- Name: m_edge_processes m_edge_processes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_edge_processes
    ADD CONSTRAINT m_edge_processes_pkey PRIMARY KEY (code);


--
-- Name: m_glosses m_glosses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_glosses
    ADD CONSTRAINT m_glosses_pkey PRIMARY KEY (code);


--
-- Name: m_grain_finishes m_grain_finishes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_grain_finishes
    ADD CONSTRAINT m_grain_finishes_pkey PRIMARY KEY (code);


--
-- Name: m_hole_diameters m_hole_diameters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_hole_diameters
    ADD CONSTRAINT m_hole_diameters_pkey PRIMARY KEY (code);


--
-- Name: m_materials m_materials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_materials
    ADD CONSTRAINT m_materials_pkey PRIMARY KEY (code);


--
-- Name: m_paint_colors m_paint_colors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_paint_colors
    ADD CONSTRAINT m_paint_colors_pkey PRIMARY KEY (code);


--
-- Name: m_paint_surfaces m_paint_surfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_paint_surfaces
    ADD CONSTRAINT m_paint_surfaces_pkey PRIMARY KEY (code);


--
-- Name: m_paint_types m_paint_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_paint_types
    ADD CONSTRAINT m_paint_types_pkey PRIMARY KEY (code);


--
-- Name: m_postal_codes m_postal_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_postal_codes
    ADD CONSTRAINT m_postal_codes_pkey PRIMARY KEY (id);


--
-- Name: m_process_types m_process_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_process_types
    ADD CONSTRAINT m_process_types_pkey PRIMARY KEY (code);


--
-- Name: m_shapes m_shapes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_shapes
    ADD CONSTRAINT m_shapes_pkey PRIMARY KEY (code);


--
-- Name: member_details member_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT member_details_pkey PRIMARY KEY (user_id);


--
-- Name: member_shipping_addresses member_shipping_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_shipping_addresses
    ADD CONSTRAINT member_shipping_addresses_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: order_reviews order_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT order_reviews_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: payouts payouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payouts
    ADD CONSTRAINT payouts_pkey PRIMARY KEY (id);


--
-- Name: quote_items quote_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_items
    ADD CONSTRAINT quote_items_pkey PRIMARY KEY (id);


--
-- Name: quote_request_comments quote_request_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_comments
    ADD CONSTRAINT quote_request_comments_pkey PRIMARY KEY (id);


--
-- Name: quote_request_items quote_request_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_items
    ADD CONSTRAINT quote_request_items_pkey PRIMARY KEY (id);


--
-- Name: quote_requests quote_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_requests
    ADD CONSTRAINT quote_requests_pkey PRIMARY KEY (id);


--
-- Name: quotes quotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT quotes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: stripe_events stripe_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_events
    ADD CONSTRAINT stripe_events_pkey PRIMARY KEY (event_id);


--
-- Name: stripe_payments stripe_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_payments
    ADD CONSTRAINT stripe_payments_pkey PRIMARY KEY (id);


--
-- Name: stripe_payouts stripe_payouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_payouts
    ADD CONSTRAINT stripe_payouts_pkey PRIMARY KEY (payout_id);


--
-- Name: stripe_refunds stripe_refunds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_refunds
    ADD CONSTRAINT stripe_refunds_pkey PRIMARY KEY (refund_id);


--
-- Name: user_authorities user_authorities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_authorities
    ADD CONSTRAINT user_authorities_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vendor_capabilities vendor_capabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_capabilities
    ADD CONSTRAINT vendor_capabilities_pkey PRIMARY KEY (vendor_id, capability_code);


--
-- Name: vendor_details vendor_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT vendor_details_pkey PRIMARY KEY (user_id);


--
-- Name: vendor_materials vendor_materials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_materials
    ADD CONSTRAINT vendor_materials_pkey PRIMARY KEY (vendor_id, material_code);


--
-- Name: vendor_service_areas vendor_service_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_service_areas
    ADD CONSTRAINT vendor_service_areas_pkey PRIMARY KEY (vendor_id, prefecture_code, city_code);


--
-- Name: index_h_article_views_on_article_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_article_views_on_article_id ON ONLY public.h_article_views USING btree (article_id);


--
-- Name: h_article_views_202505_article_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202505_article_id_idx ON public.h_article_views_202505 USING btree (article_id);


--
-- Name: idx_article_views_unprocessed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_article_views_unprocessed ON ONLY public.h_article_views USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202505_article_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202505_article_id_idx1 ON public.h_article_views_202505 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: index_h_article_views_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_article_views_on_id ON ONLY public.h_article_views USING btree (id);


--
-- Name: h_article_views_202505_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202505_id_idx ON public.h_article_views_202505 USING btree (id);


--
-- Name: h_article_views_202505_unproc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202505_unproc_idx ON public.h_article_views_202505 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: index_h_article_views_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_article_views_on_user_id ON ONLY public.h_article_views USING btree (user_id);


--
-- Name: h_article_views_202505_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202505_user_id_idx ON public.h_article_views_202505 USING btree (user_id);


--
-- Name: h_article_views_202506_article_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202506_article_id_idx ON public.h_article_views_202506 USING btree (article_id);


--
-- Name: h_article_views_202506_article_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202506_article_id_idx1 ON public.h_article_views_202506 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202506_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202506_id_idx ON public.h_article_views_202506 USING btree (id);


--
-- Name: h_article_views_202506_unproc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202506_unproc_idx ON public.h_article_views_202506 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202506_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202506_user_id_idx ON public.h_article_views_202506 USING btree (user_id);


--
-- Name: h_article_views_202507_article_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202507_article_id_idx ON public.h_article_views_202507 USING btree (article_id);


--
-- Name: h_article_views_202507_article_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202507_article_id_idx1 ON public.h_article_views_202507 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202507_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202507_id_idx ON public.h_article_views_202507 USING btree (id);


--
-- Name: h_article_views_202507_unproc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202507_unproc_idx ON public.h_article_views_202507 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202507_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202507_user_id_idx ON public.h_article_views_202507 USING btree (user_id);


--
-- Name: h_article_views_202508_article_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202508_article_id_idx ON public.h_article_views_202508 USING btree (article_id);


--
-- Name: h_article_views_202508_article_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202508_article_id_idx1 ON public.h_article_views_202508 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202508_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202508_id_idx ON public.h_article_views_202508 USING btree (id);


--
-- Name: h_article_views_202508_unproc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202508_unproc_idx ON public.h_article_views_202508 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202508_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202508_user_id_idx ON public.h_article_views_202508 USING btree (user_id);


--
-- Name: h_article_views_202509_article_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202509_article_id_idx ON public.h_article_views_202509 USING btree (article_id);


--
-- Name: h_article_views_202509_article_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202509_article_id_idx1 ON public.h_article_views_202509 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202509_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202509_id_idx ON public.h_article_views_202509 USING btree (id);


--
-- Name: h_article_views_202509_unproc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202509_unproc_idx ON public.h_article_views_202509 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202509_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202509_user_id_idx ON public.h_article_views_202509 USING btree (user_id);


--
-- Name: h_article_views_202510_article_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202510_article_id_idx ON public.h_article_views_202510 USING btree (article_id);


--
-- Name: h_article_views_202510_article_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202510_article_id_idx1 ON public.h_article_views_202510 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202510_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202510_id_idx ON public.h_article_views_202510 USING btree (id);


--
-- Name: h_article_views_202510_unproc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202510_unproc_idx ON public.h_article_views_202510 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202510_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202510_user_id_idx ON public.h_article_views_202510 USING btree (user_id);


--
-- Name: h_article_views_202511_article_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202511_article_id_idx ON public.h_article_views_202511 USING btree (article_id);


--
-- Name: h_article_views_202511_article_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202511_article_id_idx1 ON public.h_article_views_202511 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202511_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202511_id_idx ON public.h_article_views_202511 USING btree (id);


--
-- Name: h_article_views_202511_unproc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202511_unproc_idx ON public.h_article_views_202511 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202511_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202511_user_id_idx ON public.h_article_views_202511 USING btree (user_id);


--
-- Name: h_article_views_202512_article_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202512_article_id_idx ON public.h_article_views_202512 USING btree (article_id);


--
-- Name: h_article_views_202512_article_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202512_article_id_idx1 ON public.h_article_views_202512 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202512_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202512_id_idx ON public.h_article_views_202512 USING btree (id);


--
-- Name: h_article_views_202512_unproc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202512_unproc_idx ON public.h_article_views_202512 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202512_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202512_user_id_idx ON public.h_article_views_202512 USING btree (user_id);


--
-- Name: h_article_views_202601_article_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202601_article_id_idx ON public.h_article_views_202601 USING btree (article_id);


--
-- Name: h_article_views_202601_article_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202601_article_id_idx1 ON public.h_article_views_202601 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202601_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202601_id_idx ON public.h_article_views_202601 USING btree (id);


--
-- Name: h_article_views_202601_unproc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202601_unproc_idx ON public.h_article_views_202601 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202601_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202601_user_id_idx ON public.h_article_views_202601 USING btree (user_id);


--
-- Name: h_article_views_202602_article_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202602_article_id_idx ON public.h_article_views_202602 USING btree (article_id);


--
-- Name: h_article_views_202602_article_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202602_article_id_idx1 ON public.h_article_views_202602 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202602_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202602_id_idx ON public.h_article_views_202602 USING btree (id);


--
-- Name: h_article_views_202602_unproc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202602_unproc_idx ON public.h_article_views_202602 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202602_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202602_user_id_idx ON public.h_article_views_202602 USING btree (user_id);


--
-- Name: h_article_views_202603_article_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202603_article_id_idx ON public.h_article_views_202603 USING btree (article_id);


--
-- Name: h_article_views_202603_article_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202603_article_id_idx1 ON public.h_article_views_202603 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202603_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202603_id_idx ON public.h_article_views_202603 USING btree (id);


--
-- Name: h_article_views_202603_unproc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202603_unproc_idx ON public.h_article_views_202603 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202603_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202603_user_id_idx ON public.h_article_views_202603 USING btree (user_id);


--
-- Name: h_article_views_202604_article_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202604_article_id_idx ON public.h_article_views_202604 USING btree (article_id);


--
-- Name: h_article_views_202604_article_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202604_article_id_idx1 ON public.h_article_views_202604 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202604_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202604_id_idx ON public.h_article_views_202604 USING btree (id);


--
-- Name: h_article_views_202604_unproc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202604_unproc_idx ON public.h_article_views_202604 USING btree (article_id) WHERE (processed_flag = false);


--
-- Name: h_article_views_202604_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_article_views_202604_user_id_idx ON public.h_article_views_202604 USING btree (user_id);


--
-- Name: index_h_audit_trails_on_changed_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_audit_trails_on_changed_by ON ONLY public.h_audit_trails USING btree (changed_by);


--
-- Name: h_audit_trails_202505_changed_by_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_audit_trails_202505_changed_by_idx ON public.h_audit_trails_202505 USING btree (changed_by);


--
-- Name: h_audit_trails_202505_changed_by_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_audit_trails_202505_changed_by_idx1 ON public.h_audit_trails_202505 USING btree (changed_by);


--
-- Name: index_h_audit_trails_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_audit_trails_on_id ON ONLY public.h_audit_trails USING btree (id);


--
-- Name: h_audit_trails_202505_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_audit_trails_202505_id_idx ON public.h_audit_trails_202505 USING btree (id);


--
-- Name: h_audit_trails_202505_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_audit_trails_202505_id_idx1 ON public.h_audit_trails_202505 USING btree (id);


--
-- Name: index_h_audit_trails_on_table_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_audit_trails_on_table_name ON ONLY public.h_audit_trails USING btree (table_name);


--
-- Name: h_audit_trails_202505_table_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_audit_trails_202505_table_name_idx ON public.h_audit_trails_202505 USING btree (table_name);


--
-- Name: h_audit_trails_202505_table_name_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_audit_trails_202505_table_name_idx1 ON public.h_audit_trails_202505 USING btree (table_name);


--
-- Name: index_h_error_logs_on_error_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_error_logs_on_error_class ON ONLY public.h_error_logs USING btree (error_class);


--
-- Name: h_error_logs_202505_error_class_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202505_error_class_idx ON public.h_error_logs_202505 USING btree (error_class);


--
-- Name: index_h_error_logs_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_error_logs_on_id ON ONLY public.h_error_logs USING btree (id);


--
-- Name: h_error_logs_202505_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202505_id_idx ON public.h_error_logs_202505 USING btree (id);


--
-- Name: index_h_error_logs_on_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_error_logs_on_request_id ON ONLY public.h_error_logs USING btree (request_id);


--
-- Name: h_error_logs_202505_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202505_request_id_idx ON public.h_error_logs_202505 USING btree (request_id);


--
-- Name: index_h_error_logs_on_request_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_error_logs_on_request_path ON ONLY public.h_error_logs USING btree (request_path);


--
-- Name: h_error_logs_202505_request_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202505_request_path_idx ON public.h_error_logs_202505 USING btree (request_path);


--
-- Name: index_h_error_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_error_logs_on_user_id ON ONLY public.h_error_logs USING btree (user_id);


--
-- Name: h_error_logs_202505_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202505_user_id_idx ON public.h_error_logs_202505 USING btree (user_id);


--
-- Name: h_error_logs_202506_error_class_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202506_error_class_idx ON public.h_error_logs_202506 USING btree (error_class);


--
-- Name: h_error_logs_202506_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202506_id_idx ON public.h_error_logs_202506 USING btree (id);


--
-- Name: h_error_logs_202506_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202506_request_id_idx ON public.h_error_logs_202506 USING btree (request_id);


--
-- Name: h_error_logs_202506_request_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202506_request_path_idx ON public.h_error_logs_202506 USING btree (request_path);


--
-- Name: h_error_logs_202506_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202506_user_id_idx ON public.h_error_logs_202506 USING btree (user_id);


--
-- Name: h_error_logs_202507_error_class_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202507_error_class_idx ON public.h_error_logs_202507 USING btree (error_class);


--
-- Name: h_error_logs_202507_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202507_id_idx ON public.h_error_logs_202507 USING btree (id);


--
-- Name: h_error_logs_202507_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202507_request_id_idx ON public.h_error_logs_202507 USING btree (request_id);


--
-- Name: h_error_logs_202507_request_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202507_request_path_idx ON public.h_error_logs_202507 USING btree (request_path);


--
-- Name: h_error_logs_202507_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202507_user_id_idx ON public.h_error_logs_202507 USING btree (user_id);


--
-- Name: h_error_logs_202508_error_class_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202508_error_class_idx ON public.h_error_logs_202508 USING btree (error_class);


--
-- Name: h_error_logs_202508_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202508_id_idx ON public.h_error_logs_202508 USING btree (id);


--
-- Name: h_error_logs_202508_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202508_request_id_idx ON public.h_error_logs_202508 USING btree (request_id);


--
-- Name: h_error_logs_202508_request_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202508_request_path_idx ON public.h_error_logs_202508 USING btree (request_path);


--
-- Name: h_error_logs_202508_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202508_user_id_idx ON public.h_error_logs_202508 USING btree (user_id);


--
-- Name: h_error_logs_202509_error_class_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202509_error_class_idx ON public.h_error_logs_202509 USING btree (error_class);


--
-- Name: h_error_logs_202509_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202509_id_idx ON public.h_error_logs_202509 USING btree (id);


--
-- Name: h_error_logs_202509_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202509_request_id_idx ON public.h_error_logs_202509 USING btree (request_id);


--
-- Name: h_error_logs_202509_request_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202509_request_path_idx ON public.h_error_logs_202509 USING btree (request_path);


--
-- Name: h_error_logs_202509_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202509_user_id_idx ON public.h_error_logs_202509 USING btree (user_id);


--
-- Name: h_error_logs_202510_error_class_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202510_error_class_idx ON public.h_error_logs_202510 USING btree (error_class);


--
-- Name: h_error_logs_202510_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202510_id_idx ON public.h_error_logs_202510 USING btree (id);


--
-- Name: h_error_logs_202510_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202510_request_id_idx ON public.h_error_logs_202510 USING btree (request_id);


--
-- Name: h_error_logs_202510_request_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202510_request_path_idx ON public.h_error_logs_202510 USING btree (request_path);


--
-- Name: h_error_logs_202510_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202510_user_id_idx ON public.h_error_logs_202510 USING btree (user_id);


--
-- Name: h_error_logs_202511_error_class_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202511_error_class_idx ON public.h_error_logs_202511 USING btree (error_class);


--
-- Name: h_error_logs_202511_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202511_id_idx ON public.h_error_logs_202511 USING btree (id);


--
-- Name: h_error_logs_202511_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202511_request_id_idx ON public.h_error_logs_202511 USING btree (request_id);


--
-- Name: h_error_logs_202511_request_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202511_request_path_idx ON public.h_error_logs_202511 USING btree (request_path);


--
-- Name: h_error_logs_202511_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202511_user_id_idx ON public.h_error_logs_202511 USING btree (user_id);


--
-- Name: h_error_logs_202512_error_class_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202512_error_class_idx ON public.h_error_logs_202512 USING btree (error_class);


--
-- Name: h_error_logs_202512_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202512_id_idx ON public.h_error_logs_202512 USING btree (id);


--
-- Name: h_error_logs_202512_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202512_request_id_idx ON public.h_error_logs_202512 USING btree (request_id);


--
-- Name: h_error_logs_202512_request_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202512_request_path_idx ON public.h_error_logs_202512 USING btree (request_path);


--
-- Name: h_error_logs_202512_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202512_user_id_idx ON public.h_error_logs_202512 USING btree (user_id);


--
-- Name: h_error_logs_202601_error_class_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202601_error_class_idx ON public.h_error_logs_202601 USING btree (error_class);


--
-- Name: h_error_logs_202601_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202601_id_idx ON public.h_error_logs_202601 USING btree (id);


--
-- Name: h_error_logs_202601_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202601_request_id_idx ON public.h_error_logs_202601 USING btree (request_id);


--
-- Name: h_error_logs_202601_request_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202601_request_path_idx ON public.h_error_logs_202601 USING btree (request_path);


--
-- Name: h_error_logs_202601_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202601_user_id_idx ON public.h_error_logs_202601 USING btree (user_id);


--
-- Name: h_error_logs_202602_error_class_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202602_error_class_idx ON public.h_error_logs_202602 USING btree (error_class);


--
-- Name: h_error_logs_202602_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202602_id_idx ON public.h_error_logs_202602 USING btree (id);


--
-- Name: h_error_logs_202602_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202602_request_id_idx ON public.h_error_logs_202602 USING btree (request_id);


--
-- Name: h_error_logs_202602_request_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202602_request_path_idx ON public.h_error_logs_202602 USING btree (request_path);


--
-- Name: h_error_logs_202602_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202602_user_id_idx ON public.h_error_logs_202602 USING btree (user_id);


--
-- Name: h_error_logs_202603_error_class_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202603_error_class_idx ON public.h_error_logs_202603 USING btree (error_class);


--
-- Name: h_error_logs_202603_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202603_id_idx ON public.h_error_logs_202603 USING btree (id);


--
-- Name: h_error_logs_202603_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202603_request_id_idx ON public.h_error_logs_202603 USING btree (request_id);


--
-- Name: h_error_logs_202603_request_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202603_request_path_idx ON public.h_error_logs_202603 USING btree (request_path);


--
-- Name: h_error_logs_202603_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202603_user_id_idx ON public.h_error_logs_202603 USING btree (user_id);


--
-- Name: h_error_logs_202604_error_class_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202604_error_class_idx ON public.h_error_logs_202604 USING btree (error_class);


--
-- Name: h_error_logs_202604_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202604_id_idx ON public.h_error_logs_202604 USING btree (id);


--
-- Name: h_error_logs_202604_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202604_request_id_idx ON public.h_error_logs_202604 USING btree (request_id);


--
-- Name: h_error_logs_202604_request_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202604_request_path_idx ON public.h_error_logs_202604 USING btree (request_path);


--
-- Name: h_error_logs_202604_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_error_logs_202604_user_id_idx ON public.h_error_logs_202604 USING btree (user_id);


--
-- Name: index_h_login_attempts_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_login_attempts_on_id ON ONLY public.h_login_attempts USING btree (id);


--
-- Name: h_login_attempts_202505_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_login_attempts_202505_id_idx ON public.h_login_attempts_202505 USING btree (id);


--
-- Name: h_login_attempts_202505_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_login_attempts_202505_id_idx1 ON public.h_login_attempts_202505 USING btree (id);


--
-- Name: index_h_login_attempts_on_ip_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_login_attempts_on_ip_address ON ONLY public.h_login_attempts USING btree (ip_address);


--
-- Name: h_login_attempts_202505_ip_address_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_login_attempts_202505_ip_address_idx ON public.h_login_attempts_202505 USING btree (ip_address);


--
-- Name: h_login_attempts_202505_ip_address_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_login_attempts_202505_ip_address_idx1 ON public.h_login_attempts_202505 USING btree (ip_address);


--
-- Name: index_h_login_attempts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_login_attempts_on_user_id ON ONLY public.h_login_attempts USING btree (user_id);


--
-- Name: h_login_attempts_202505_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_login_attempts_202505_user_id_idx ON public.h_login_attempts_202505 USING btree (user_id);


--
-- Name: h_login_attempts_202505_user_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_login_attempts_202505_user_id_idx1 ON public.h_login_attempts_202505 USING btree (user_id);


--
-- Name: idx_hpwebhook_gateway_event; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_hpwebhook_gateway_event ON ONLY public.h_payment_webhooks USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202505_gateway_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_payment_webhooks_202505_gateway_event_id_idx ON public.h_payment_webhooks_202505 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202505_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX h_payment_webhooks_202505_uq ON public.h_payment_webhooks_202505 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202506_gateway_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_payment_webhooks_202506_gateway_event_id_idx ON public.h_payment_webhooks_202506 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202506_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX h_payment_webhooks_202506_uq ON public.h_payment_webhooks_202506 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202507_gateway_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_payment_webhooks_202507_gateway_event_id_idx ON public.h_payment_webhooks_202507 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202507_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX h_payment_webhooks_202507_uq ON public.h_payment_webhooks_202507 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202508_gateway_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_payment_webhooks_202508_gateway_event_id_idx ON public.h_payment_webhooks_202508 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202508_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX h_payment_webhooks_202508_uq ON public.h_payment_webhooks_202508 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202509_gateway_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_payment_webhooks_202509_gateway_event_id_idx ON public.h_payment_webhooks_202509 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202509_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX h_payment_webhooks_202509_uq ON public.h_payment_webhooks_202509 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202510_gateway_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_payment_webhooks_202510_gateway_event_id_idx ON public.h_payment_webhooks_202510 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202510_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX h_payment_webhooks_202510_uq ON public.h_payment_webhooks_202510 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202511_gateway_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_payment_webhooks_202511_gateway_event_id_idx ON public.h_payment_webhooks_202511 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202511_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX h_payment_webhooks_202511_uq ON public.h_payment_webhooks_202511 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202512_gateway_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_payment_webhooks_202512_gateway_event_id_idx ON public.h_payment_webhooks_202512 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202512_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX h_payment_webhooks_202512_uq ON public.h_payment_webhooks_202512 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202601_gateway_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_payment_webhooks_202601_gateway_event_id_idx ON public.h_payment_webhooks_202601 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202601_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX h_payment_webhooks_202601_uq ON public.h_payment_webhooks_202601 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202602_gateway_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_payment_webhooks_202602_gateway_event_id_idx ON public.h_payment_webhooks_202602 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202602_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX h_payment_webhooks_202602_uq ON public.h_payment_webhooks_202602 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202603_gateway_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_payment_webhooks_202603_gateway_event_id_idx ON public.h_payment_webhooks_202603 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202603_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX h_payment_webhooks_202603_uq ON public.h_payment_webhooks_202603 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202604_gateway_event_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX h_payment_webhooks_202604_gateway_event_id_idx ON public.h_payment_webhooks_202604 USING btree (gateway, event_id);


--
-- Name: h_payment_webhooks_202604_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX h_payment_webhooks_202604_uq ON public.h_payment_webhooks_202604 USING btree (gateway, event_id);


--
-- Name: idx_article_comments_author_polymorphic; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_article_comments_author_polymorphic ON public.article_comments USING btree (author_type, author_id);


--
-- Name: idx_hpe_logger; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_hpe_logger ON public.h_payout_events USING btree (logged_by_type, logged_by_id);


--
-- Name: idx_notifications_recipient_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_recipient_status ON public.notifications USING btree (recipient_type, recipient_id, status);


--
-- Name: idx_notifications_related; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_related ON public.notifications USING btree (related_model_type, related_model_id);


--
-- Name: idx_postal_code_area_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_postal_code_area_unique ON public.m_postal_codes USING btree (postal_code, town_area_name_kanji);


--
-- Name: idx_qr_comments_author_polymorphic; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qr_comments_author_polymorphic ON public.quote_request_comments USING btree (author_type, author_id);


--
-- Name: index_admin_details_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_details_on_created_by_id ON public.admin_details USING btree (created_by_id);


--
-- Name: index_admin_details_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_details_on_deleted_by_id ON public.admin_details USING btree (deleted_by_id);


--
-- Name: index_admin_details_on_nickname; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_details_on_nickname ON public.admin_details USING btree (nickname);


--
-- Name: index_admin_details_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_details_on_updated_by_id ON public.admin_details USING btree (updated_by_id);


--
-- Name: index_affiliate_commissions_on_affiliate_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliate_commissions_on_affiliate_user_id ON public.affiliate_commissions USING btree (affiliate_user_id);


--
-- Name: index_affiliate_commissions_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliate_commissions_on_created_by_id ON public.affiliate_commissions USING btree (created_by_id);


--
-- Name: index_affiliate_commissions_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliate_commissions_on_deleted_by_id ON public.affiliate_commissions USING btree (deleted_by_id);


--
-- Name: index_affiliate_commissions_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliate_commissions_on_order_id ON public.affiliate_commissions USING btree (order_id);


--
-- Name: index_affiliate_commissions_on_referred_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliate_commissions_on_referred_user_id ON public.affiliate_commissions USING btree (referred_user_id);


--
-- Name: index_affiliate_commissions_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliate_commissions_on_updated_by_id ON public.affiliate_commissions USING btree (updated_by_id);


--
-- Name: index_affiliate_details_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliate_details_on_created_by_id ON public.affiliate_details USING btree (created_by_id);


--
-- Name: index_affiliate_details_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliate_details_on_deleted_by_id ON public.affiliate_details USING btree (deleted_by_id);


--
-- Name: index_affiliate_details_on_invoice_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_affiliate_details_on_invoice_number ON public.affiliate_details USING btree (invoice_number);


--
-- Name: index_affiliate_details_on_stripe_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliate_details_on_stripe_account_id ON public.affiliate_details USING btree (stripe_account_id);


--
-- Name: index_affiliate_details_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliate_details_on_updated_by_id ON public.affiliate_details USING btree (updated_by_id);


--
-- Name: index_affiliate_signups_on_affiliate_click_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliate_signups_on_affiliate_click_id ON public.affiliate_signups USING btree (affiliate_click_id);


--
-- Name: index_affiliate_signups_on_affiliate_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliate_signups_on_affiliate_user_id ON public.affiliate_signups USING btree (affiliate_user_id);


--
-- Name: index_affiliate_signups_on_signup_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_affiliate_signups_on_signup_user_id ON public.affiliate_signups USING btree (signup_user_id);


--
-- Name: index_article_comments_on_article_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_comments_on_article_id ON public.article_comments USING btree (article_id);


--
-- Name: index_article_comments_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_comments_on_author_id ON public.article_comments USING btree (author_id);


--
-- Name: index_article_comments_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_comments_on_created_by_id ON public.article_comments USING btree (created_by_id);


--
-- Name: index_article_comments_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_comments_on_deleted_by_id ON public.article_comments USING btree (deleted_by_id);


--
-- Name: index_article_comments_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_comments_on_parent_id ON public.article_comments USING btree (parent_id);


--
-- Name: index_article_comments_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_comments_on_updated_by_id ON public.article_comments USING btree (updated_by_id);


--
-- Name: index_article_likes_on_article_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_likes_on_article_id ON public.article_likes USING btree (article_id);


--
-- Name: index_article_likes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_likes_on_user_id ON public.article_likes USING btree (user_id);


--
-- Name: index_article_media_on_article_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_media_on_article_id ON public.article_media USING btree (article_id);


--
-- Name: index_article_media_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_media_on_created_by_id ON public.article_media USING btree (created_by_id);


--
-- Name: index_article_media_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_media_on_deleted_by_id ON public.article_media USING btree (deleted_by_id);


--
-- Name: index_article_media_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_article_media_on_updated_by_id ON public.article_media USING btree (updated_by_id);


--
-- Name: index_articles_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_articles_on_author_type_and_author_id ON public.articles USING btree (author_type, author_id);


--
-- Name: index_articles_on_content_blocks; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_articles_on_content_blocks ON public.articles USING gin (content_blocks);


--
-- Name: index_articles_on_likes_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_articles_on_likes_count ON public.articles USING btree (likes_count);


--
-- Name: index_articles_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_articles_on_order_id ON public.articles USING btree (order_id);


--
-- Name: index_articles_on_replies_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_articles_on_replies_count ON public.articles USING btree (replies_count);


--
-- Name: index_articles_on_views_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_articles_on_views_count ON public.articles USING btree (views_count);


--
-- Name: index_h_affiliate_clicks_on_affiliate_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_affiliate_clicks_on_affiliate_user_id ON public.h_affiliate_clicks USING btree (affiliate_user_id);


--
-- Name: index_h_payout_events_on_event; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_payout_events_on_event ON public.h_payout_events USING btree (event);


--
-- Name: index_h_payout_events_on_occurred_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_payout_events_on_occurred_at ON public.h_payout_events USING btree (occurred_at);


--
-- Name: index_h_payout_events_on_payout_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_h_payout_events_on_payout_id ON public.h_payout_events USING btree (payout_id);


--
-- Name: index_m_authorities_on_active_flag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_authorities_on_active_flag ON public.m_authorities USING btree (active_flag);


--
-- Name: index_m_authorities_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_authorities_on_code ON public.m_authorities USING btree (code);


--
-- Name: index_m_authorities_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_authorities_on_created_by_id ON public.m_authorities USING btree (created_by_id);


--
-- Name: index_m_authorities_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_authorities_on_deleted_by_id ON public.m_authorities USING btree (deleted_by_id);


--
-- Name: index_m_authorities_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_authorities_on_updated_by_id ON public.m_authorities USING btree (updated_by_id);


--
-- Name: index_m_categories_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_categories_on_code ON public.m_categories USING btree (code);


--
-- Name: index_m_categories_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_categories_on_created_by_id ON public.m_categories USING btree (created_by_id);


--
-- Name: index_m_categories_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_categories_on_deleted_by_id ON public.m_categories USING btree (deleted_by_id);


--
-- Name: index_m_categories_on_name_en; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_categories_on_name_en ON public.m_categories USING btree (name_en);


--
-- Name: index_m_categories_on_name_ja; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_categories_on_name_ja ON public.m_categories USING btree (name_ja);


--
-- Name: index_m_categories_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_categories_on_updated_by_id ON public.m_categories USING btree (updated_by_id);


--
-- Name: index_m_cities_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_cities_on_code ON public.m_cities USING btree (code);


--
-- Name: index_m_cities_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_cities_on_created_by_id ON public.m_cities USING btree (created_by_id);


--
-- Name: index_m_cities_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_cities_on_deleted_by_id ON public.m_cities USING btree (deleted_by_id);


--
-- Name: index_m_cities_on_prefecture_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_cities_on_prefecture_code ON public.m_cities USING btree (prefecture_code);


--
-- Name: index_m_cities_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_cities_on_updated_by_id ON public.m_cities USING btree (updated_by_id);


--
-- Name: index_m_corner_processes_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_corner_processes_on_created_by_id ON public.m_corner_processes USING btree (created_by_id);


--
-- Name: index_m_corner_processes_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_corner_processes_on_deleted_by_id ON public.m_corner_processes USING btree (deleted_by_id);


--
-- Name: index_m_corner_processes_on_name_en; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_corner_processes_on_name_en ON public.m_corner_processes USING btree (name_en);


--
-- Name: index_m_corner_processes_on_name_ja; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_corner_processes_on_name_ja ON public.m_corner_processes USING btree (name_ja);


--
-- Name: index_m_corner_processes_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_corner_processes_on_updated_by_id ON public.m_corner_processes USING btree (updated_by_id);


--
-- Name: index_m_edge_processes_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_edge_processes_on_created_by_id ON public.m_edge_processes USING btree (created_by_id);


--
-- Name: index_m_edge_processes_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_edge_processes_on_deleted_by_id ON public.m_edge_processes USING btree (deleted_by_id);


--
-- Name: index_m_edge_processes_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_edge_processes_on_updated_by_id ON public.m_edge_processes USING btree (updated_by_id);


--
-- Name: index_m_glosses_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_glosses_on_created_by_id ON public.m_glosses USING btree (created_by_id);


--
-- Name: index_m_glosses_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_glosses_on_deleted_by_id ON public.m_glosses USING btree (deleted_by_id);


--
-- Name: index_m_glosses_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_glosses_on_updated_by_id ON public.m_glosses USING btree (updated_by_id);


--
-- Name: index_m_grain_finishes_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_grain_finishes_on_created_by_id ON public.m_grain_finishes USING btree (created_by_id);


--
-- Name: index_m_grain_finishes_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_grain_finishes_on_deleted_by_id ON public.m_grain_finishes USING btree (deleted_by_id);


--
-- Name: index_m_grain_finishes_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_grain_finishes_on_updated_by_id ON public.m_grain_finishes USING btree (updated_by_id);


--
-- Name: index_m_hole_diameters_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_hole_diameters_on_created_by_id ON public.m_hole_diameters USING btree (created_by_id);


--
-- Name: index_m_hole_diameters_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_hole_diameters_on_deleted_by_id ON public.m_hole_diameters USING btree (deleted_by_id);


--
-- Name: index_m_hole_diameters_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_hole_diameters_on_updated_by_id ON public.m_hole_diameters USING btree (updated_by_id);


--
-- Name: index_m_materials_on_category_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_materials_on_category_code ON public.m_materials USING btree (category_code);


--
-- Name: index_m_materials_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_materials_on_created_by_id ON public.m_materials USING btree (created_by_id);


--
-- Name: index_m_materials_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_materials_on_deleted_by_id ON public.m_materials USING btree (deleted_by_id);


--
-- Name: index_m_materials_on_name_en; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_materials_on_name_en ON public.m_materials USING btree (name_en);


--
-- Name: index_m_materials_on_name_ja; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_materials_on_name_ja ON public.m_materials USING btree (name_ja);


--
-- Name: index_m_materials_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_materials_on_updated_by_id ON public.m_materials USING btree (updated_by_id);


--
-- Name: index_m_paint_colors_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_paint_colors_on_created_by_id ON public.m_paint_colors USING btree (created_by_id);


--
-- Name: index_m_paint_colors_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_paint_colors_on_deleted_by_id ON public.m_paint_colors USING btree (deleted_by_id);


--
-- Name: index_m_paint_colors_on_name_en; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_paint_colors_on_name_en ON public.m_paint_colors USING btree (name_en);


--
-- Name: index_m_paint_colors_on_name_ja; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_paint_colors_on_name_ja ON public.m_paint_colors USING btree (name_ja);


--
-- Name: index_m_paint_colors_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_paint_colors_on_updated_by_id ON public.m_paint_colors USING btree (updated_by_id);


--
-- Name: index_m_paint_surfaces_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_paint_surfaces_on_created_by_id ON public.m_paint_surfaces USING btree (created_by_id);


--
-- Name: index_m_paint_surfaces_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_paint_surfaces_on_deleted_by_id ON public.m_paint_surfaces USING btree (deleted_by_id);


--
-- Name: index_m_paint_surfaces_on_name_en; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_paint_surfaces_on_name_en ON public.m_paint_surfaces USING btree (name_en);


--
-- Name: index_m_paint_surfaces_on_name_ja; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_paint_surfaces_on_name_ja ON public.m_paint_surfaces USING btree (name_ja);


--
-- Name: index_m_paint_surfaces_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_paint_surfaces_on_updated_by_id ON public.m_paint_surfaces USING btree (updated_by_id);


--
-- Name: index_m_paint_types_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_paint_types_on_created_by_id ON public.m_paint_types USING btree (created_by_id);


--
-- Name: index_m_paint_types_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_paint_types_on_deleted_by_id ON public.m_paint_types USING btree (deleted_by_id);


--
-- Name: index_m_paint_types_on_name_en; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_paint_types_on_name_en ON public.m_paint_types USING btree (name_en);


--
-- Name: index_m_paint_types_on_name_ja; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_paint_types_on_name_ja ON public.m_paint_types USING btree (name_ja);


--
-- Name: index_m_paint_types_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_paint_types_on_updated_by_id ON public.m_paint_types USING btree (updated_by_id);


--
-- Name: index_m_postal_codes_on_city_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_postal_codes_on_city_code ON public.m_postal_codes USING btree (city_code);


--
-- Name: index_m_postal_codes_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_postal_codes_on_created_by_id ON public.m_postal_codes USING btree (created_by_id);


--
-- Name: index_m_postal_codes_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_postal_codes_on_deleted_by_id ON public.m_postal_codes USING btree (deleted_by_id);


--
-- Name: index_m_postal_codes_on_postal_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_postal_codes_on_postal_code ON public.m_postal_codes USING btree (postal_code);


--
-- Name: index_m_postal_codes_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_postal_codes_on_updated_by_id ON public.m_postal_codes USING btree (updated_by_id);


--
-- Name: index_m_prefectures_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_prefectures_on_code ON public.m_prefectures USING btree (code);


--
-- Name: index_m_prefectures_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_prefectures_on_created_by_id ON public.m_prefectures USING btree (created_by_id);


--
-- Name: index_m_prefectures_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_prefectures_on_deleted_by_id ON public.m_prefectures USING btree (deleted_by_id);


--
-- Name: index_m_prefectures_on_name_ja; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_prefectures_on_name_ja ON public.m_prefectures USING btree (name_ja);


--
-- Name: index_m_prefectures_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_prefectures_on_updated_by_id ON public.m_prefectures USING btree (updated_by_id);


--
-- Name: index_m_process_types_on_category_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_process_types_on_category_code ON public.m_process_types USING btree (category_code);


--
-- Name: index_m_process_types_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_process_types_on_created_by_id ON public.m_process_types USING btree (created_by_id);


--
-- Name: index_m_process_types_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_process_types_on_deleted_by_id ON public.m_process_types USING btree (deleted_by_id);


--
-- Name: index_m_process_types_on_name_en; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_process_types_on_name_en ON public.m_process_types USING btree (name_en);


--
-- Name: index_m_process_types_on_name_ja; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_process_types_on_name_ja ON public.m_process_types USING btree (name_ja);


--
-- Name: index_m_process_types_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_process_types_on_updated_by_id ON public.m_process_types USING btree (updated_by_id);


--
-- Name: index_m_shapes_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_shapes_on_created_by_id ON public.m_shapes USING btree (created_by_id);


--
-- Name: index_m_shapes_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_shapes_on_deleted_by_id ON public.m_shapes USING btree (deleted_by_id);


--
-- Name: index_m_shapes_on_name_en; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_shapes_on_name_en ON public.m_shapes USING btree (name_en);


--
-- Name: index_m_shapes_on_name_ja; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_m_shapes_on_name_ja ON public.m_shapes USING btree (name_ja);


--
-- Name: index_m_shapes_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_shapes_on_updated_by_id ON public.m_shapes USING btree (updated_by_id);


--
-- Name: index_member_details_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_member_details_on_created_by_id ON public.member_details USING btree (created_by_id);


--
-- Name: index_member_details_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_member_details_on_deleted_by_id ON public.member_details USING btree (deleted_by_id);


--
-- Name: index_member_details_on_registered_affiliate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_member_details_on_registered_affiliate_id ON public.member_details USING btree (registered_affiliate_id);


--
-- Name: index_member_details_on_stripe_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_member_details_on_stripe_customer_id ON public.member_details USING btree (stripe_customer_id);


--
-- Name: index_member_details_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_member_details_on_updated_by_id ON public.member_details USING btree (updated_by_id);


--
-- Name: index_member_shipping_addresses_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_member_shipping_addresses_on_created_by_id ON public.member_shipping_addresses USING btree (created_by_id);


--
-- Name: index_member_shipping_addresses_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_member_shipping_addresses_on_deleted_by_id ON public.member_shipping_addresses USING btree (deleted_by_id);


--
-- Name: index_member_shipping_addresses_on_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_member_shipping_addresses_on_member_id ON public.member_shipping_addresses USING btree (member_id);


--
-- Name: index_member_shipping_addresses_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_member_shipping_addresses_on_updated_by_id ON public.member_shipping_addresses USING btree (updated_by_id);


--
-- Name: index_notifications_on_broadcast_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_broadcast_id ON public.notifications USING btree (broadcast_id);


--
-- Name: index_notifications_on_notification_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_notification_type ON public.notifications USING btree (notification_type);


--
-- Name: index_order_reviews_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_reviews_on_created_by_id ON public.order_reviews USING btree (created_by_id);


--
-- Name: index_order_reviews_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_reviews_on_deleted_by_id ON public.order_reviews USING btree (deleted_by_id);


--
-- Name: index_order_reviews_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_order_reviews_on_order_id ON public.order_reviews USING btree (order_id);


--
-- Name: index_order_reviews_on_reviewer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_reviews_on_reviewer_id ON public.order_reviews USING btree (reviewer_id);


--
-- Name: index_order_reviews_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_reviews_on_updated_by_id ON public.order_reviews USING btree (updated_by_id);


--
-- Name: index_order_reviews_on_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_order_reviews_on_vendor_id ON public.order_reviews USING btree (vendor_id);


--
-- Name: index_orders_on_affiliate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_affiliate_id ON public.orders USING btree (affiliate_id);


--
-- Name: index_orders_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_created_by_id ON public.orders USING btree (created_by_id);


--
-- Name: index_orders_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_deleted_by_id ON public.orders USING btree (deleted_by_id);


--
-- Name: index_orders_on_quote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_quote_id ON public.orders USING btree (quote_id);


--
-- Name: index_orders_on_shipping_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_shipping_address_id ON public.orders USING btree (shipping_address_id);


--
-- Name: index_orders_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_updated_by_id ON public.orders USING btree (updated_by_id);


--
-- Name: index_orders_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_user_id ON public.orders USING btree (user_id);


--
-- Name: index_orders_on_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_vendor_id ON public.orders USING btree (vendor_id);


--
-- Name: index_payouts_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payouts_on_created_by_id ON public.payouts USING btree (created_by_id);


--
-- Name: index_payouts_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payouts_on_deleted_by_id ON public.payouts USING btree (deleted_by_id);


--
-- Name: index_payouts_on_payee_type_and_payee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payouts_on_payee_type_and_payee_id ON public.payouts USING btree (payee_type, payee_id);


--
-- Name: index_payouts_on_transaction_ref; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_payouts_on_transaction_ref ON public.payouts USING btree (transaction_ref);


--
-- Name: index_payouts_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payouts_on_updated_by_id ON public.payouts USING btree (updated_by_id);


--
-- Name: index_quote_items_on_corner_proc_json; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_items_on_corner_proc_json ON public.quote_items USING gin (corner_proc_json);


--
-- Name: index_quote_items_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_items_on_created_by_id ON public.quote_items USING btree (created_by_id);


--
-- Name: index_quote_items_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_items_on_deleted_by_id ON public.quote_items USING btree (deleted_by_id);


--
-- Name: index_quote_items_on_hole_json; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_items_on_hole_json ON public.quote_items USING gin (hole_json);


--
-- Name: index_quote_items_on_material_category_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_items_on_material_category_code ON public.quote_items USING btree (material_category_code);


--
-- Name: index_quote_items_on_material_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_items_on_material_code ON public.quote_items USING btree (material_code);


--
-- Name: index_quote_items_on_paint_type_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_items_on_paint_type_code ON public.quote_items USING btree (paint_type_code);


--
-- Name: index_quote_items_on_quote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_items_on_quote_id ON public.quote_items USING btree (quote_id);


--
-- Name: index_quote_items_on_quote_id_and_line_no; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_quote_items_on_quote_id_and_line_no ON public.quote_items USING btree (quote_id, line_no);


--
-- Name: index_quote_items_on_shape_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_items_on_shape_code ON public.quote_items USING btree (shape_code);


--
-- Name: index_quote_items_on_sqhole_json; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_items_on_sqhole_json ON public.quote_items USING gin (sqhole_json);


--
-- Name: index_quote_items_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_items_on_updated_by_id ON public.quote_items USING btree (updated_by_id);


--
-- Name: index_quote_request_comments_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_request_comments_on_created_by_id ON public.quote_request_comments USING btree (created_by_id);


--
-- Name: index_quote_request_comments_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_request_comments_on_deleted_by_id ON public.quote_request_comments USING btree (deleted_by_id);


--
-- Name: index_quote_request_comments_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_request_comments_on_parent_id ON public.quote_request_comments USING btree (parent_id);


--
-- Name: index_quote_request_comments_on_quote_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_request_comments_on_quote_request_id ON public.quote_request_comments USING btree (quote_request_id);


--
-- Name: index_quote_request_comments_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_request_comments_on_updated_by_id ON public.quote_request_comments USING btree (updated_by_id);


--
-- Name: index_quote_request_items_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_request_items_on_created_by_id ON public.quote_request_items USING btree (created_by_id);


--
-- Name: index_quote_request_items_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_request_items_on_deleted_by_id ON public.quote_request_items USING btree (deleted_by_id);


--
-- Name: index_quote_request_items_on_quote_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_request_items_on_quote_item_id ON public.quote_request_items USING btree (quote_item_id);


--
-- Name: index_quote_request_items_on_quote_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_request_items_on_quote_request_id ON public.quote_request_items USING btree (quote_request_id);


--
-- Name: index_quote_request_items_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_request_items_on_updated_by_id ON public.quote_request_items USING btree (updated_by_id);


--
-- Name: index_quote_requests_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_requests_on_created_by_id ON public.quote_requests USING btree (created_by_id);


--
-- Name: index_quote_requests_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_requests_on_deleted_by_id ON public.quote_requests USING btree (deleted_by_id);


--
-- Name: index_quote_requests_on_quote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_requests_on_quote_id ON public.quote_requests USING btree (quote_id);


--
-- Name: index_quote_requests_on_quote_id_and_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_quote_requests_on_quote_id_and_vendor_id ON public.quote_requests USING btree (quote_id, vendor_id);


--
-- Name: index_quote_requests_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_requests_on_updated_by_id ON public.quote_requests USING btree (updated_by_id);


--
-- Name: index_quote_requests_on_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quote_requests_on_vendor_id ON public.quote_requests USING btree (vendor_id);


--
-- Name: index_quotes_on_accepted_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_quotes_on_accepted_request_id ON public.quotes USING btree (accepted_request_id);


--
-- Name: index_quotes_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotes_on_created_by_id ON public.quotes USING btree (created_by_id);


--
-- Name: index_quotes_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotes_on_deleted_by_id ON public.quotes USING btree (deleted_by_id);


--
-- Name: index_quotes_on_shipping_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotes_on_shipping_address_id ON public.quotes USING btree (shipping_address_id);


--
-- Name: index_quotes_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotes_on_updated_by_id ON public.quotes USING btree (updated_by_id);


--
-- Name: index_quotes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotes_on_user_id ON public.quotes USING btree (user_id);


--
-- Name: index_stripe_accounts_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_accounts_on_created_by_id ON public.stripe_accounts USING btree (created_by_id);


--
-- Name: index_stripe_accounts_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_accounts_on_deleted_by_id ON public.stripe_accounts USING btree (deleted_by_id);


--
-- Name: index_stripe_accounts_on_stripe_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_accounts_on_stripe_account_id ON public.stripe_accounts USING btree (stripe_account_id);


--
-- Name: index_stripe_accounts_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_accounts_on_updated_by_id ON public.stripe_accounts USING btree (updated_by_id);


--
-- Name: index_stripe_events_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_events_on_account_id ON public.stripe_events USING btree (account_id);


--
-- Name: index_stripe_events_on_processed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_events_on_processed_at ON public.stripe_events USING btree (processed_at);


--
-- Name: index_stripe_events_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_events_on_status ON public.stripe_events USING btree (status);


--
-- Name: index_stripe_payments_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_payments_on_created_by_id ON public.stripe_payments USING btree (created_by_id);


--
-- Name: index_stripe_payments_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_payments_on_deleted_by_id ON public.stripe_payments USING btree (deleted_by_id);


--
-- Name: index_stripe_payments_on_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_payments_on_order_id ON public.stripe_payments USING btree (order_id);


--
-- Name: index_stripe_payments_on_payment_intent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stripe_payments_on_payment_intent_id ON public.stripe_payments USING btree (payment_intent_id);


--
-- Name: index_stripe_payments_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_payments_on_updated_by_id ON public.stripe_payments USING btree (updated_by_id);


--
-- Name: index_stripe_payouts_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_payouts_on_created_by_id ON public.stripe_payouts USING btree (created_by_id);


--
-- Name: index_stripe_payouts_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_payouts_on_deleted_by_id ON public.stripe_payouts USING btree (deleted_by_id);


--
-- Name: index_stripe_payouts_on_stripe_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_payouts_on_stripe_account_id ON public.stripe_payouts USING btree (stripe_account_id);


--
-- Name: index_stripe_payouts_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_payouts_on_updated_by_id ON public.stripe_payouts USING btree (updated_by_id);


--
-- Name: index_stripe_refunds_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_refunds_on_created_by_id ON public.stripe_refunds USING btree (created_by_id);


--
-- Name: index_stripe_refunds_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_refunds_on_deleted_by_id ON public.stripe_refunds USING btree (deleted_by_id);


--
-- Name: index_stripe_refunds_on_payment_intent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_refunds_on_payment_intent_id ON public.stripe_refunds USING btree (payment_intent_id);


--
-- Name: index_stripe_refunds_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_refunds_on_updated_by_id ON public.stripe_refunds USING btree (updated_by_id);


--
-- Name: index_user_authorities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_authorities_on_user_id ON public.user_authorities USING btree (user_id);


--
-- Name: index_user_authorities_on_user_id_and_authority_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_authorities_on_user_id_and_authority_code ON public.user_authorities USING btree (user_id, authority_code);


--
-- Name: index_users_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_created_by_id ON public.users USING btree (created_by_id);


--
-- Name: index_users_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_deleted_by_id ON public.users USING btree (deleted_by_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_public_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_public_uid ON public.users USING btree (public_uid);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: index_users_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_updated_by_id ON public.users USING btree (updated_by_id);


--
-- Name: index_vendor_capabilities_on_capability_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_capabilities_on_capability_code ON public.vendor_capabilities USING btree (capability_code);


--
-- Name: index_vendor_capabilities_on_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_capabilities_on_vendor_id ON public.vendor_capabilities USING btree (vendor_id);


--
-- Name: index_vendor_details_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_details_on_created_by_id ON public.vendor_details USING btree (created_by_id);


--
-- Name: index_vendor_details_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_details_on_deleted_by_id ON public.vendor_details USING btree (deleted_by_id);


--
-- Name: index_vendor_details_on_invoice_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vendor_details_on_invoice_number ON public.vendor_details USING btree (invoice_number);


--
-- Name: index_vendor_details_on_stripe_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_details_on_stripe_account_id ON public.vendor_details USING btree (stripe_account_id);


--
-- Name: index_vendor_details_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_details_on_updated_by_id ON public.vendor_details USING btree (updated_by_id);


--
-- Name: index_vendor_materials_on_material_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_materials_on_material_code ON public.vendor_materials USING btree (material_code);


--
-- Name: index_vendor_materials_on_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_materials_on_vendor_id ON public.vendor_materials USING btree (vendor_id);


--
-- Name: index_vendor_service_areas_on_city_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_service_areas_on_city_code ON public.vendor_service_areas USING btree (city_code);


--
-- Name: index_vendor_service_areas_on_prefecture_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_service_areas_on_prefecture_code ON public.vendor_service_areas USING btree (prefecture_code);


--
-- Name: index_vendor_service_areas_on_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vendor_service_areas_on_vendor_id ON public.vendor_service_areas USING btree (vendor_id);


--
-- Name: uq_aff_comm_order; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_aff_comm_order ON public.affiliate_commissions USING btree (order_id);


--
-- Name: uq_article_likes_article_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_article_likes_article_user ON public.article_likes USING btree (article_id, user_id);


--
-- Name: uq_h_aff_click_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_h_aff_click_token ON public.h_affiliate_clicks USING btree (click_token);


--
-- Name: uq_member_default_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_member_default_address ON public.member_shipping_addresses USING btree (member_id) WHERE (is_default = true);


--
-- Name: uq_orders_quote_request; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_orders_quote_request ON public.orders USING btree (quote_request_id);


--
-- Name: uq_payouts_period; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_payouts_period ON public.payouts USING btree (payee_type, payee_id, period_from, period_to);


--
-- Name: uq_quote_request_item; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_quote_request_item ON public.quote_request_items USING btree (quote_request_id, quote_item_id);


--
-- Name: h_article_views_202505_article_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_article_id ATTACH PARTITION public.h_article_views_202505_article_id_idx;


--
-- Name: h_article_views_202505_article_id_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_article_views_unprocessed ATTACH PARTITION public.h_article_views_202505_article_id_idx1;


--
-- Name: h_article_views_202505_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_id ATTACH PARTITION public.h_article_views_202505_id_idx;


--
-- Name: h_article_views_202505_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_user_id ATTACH PARTITION public.h_article_views_202505_user_id_idx;


--
-- Name: h_article_views_202506_article_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_article_id ATTACH PARTITION public.h_article_views_202506_article_id_idx;


--
-- Name: h_article_views_202506_article_id_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_article_views_unprocessed ATTACH PARTITION public.h_article_views_202506_article_id_idx1;


--
-- Name: h_article_views_202506_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_id ATTACH PARTITION public.h_article_views_202506_id_idx;


--
-- Name: h_article_views_202506_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_user_id ATTACH PARTITION public.h_article_views_202506_user_id_idx;


--
-- Name: h_article_views_202507_article_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_article_id ATTACH PARTITION public.h_article_views_202507_article_id_idx;


--
-- Name: h_article_views_202507_article_id_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_article_views_unprocessed ATTACH PARTITION public.h_article_views_202507_article_id_idx1;


--
-- Name: h_article_views_202507_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_id ATTACH PARTITION public.h_article_views_202507_id_idx;


--
-- Name: h_article_views_202507_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_user_id ATTACH PARTITION public.h_article_views_202507_user_id_idx;


--
-- Name: h_article_views_202508_article_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_article_id ATTACH PARTITION public.h_article_views_202508_article_id_idx;


--
-- Name: h_article_views_202508_article_id_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_article_views_unprocessed ATTACH PARTITION public.h_article_views_202508_article_id_idx1;


--
-- Name: h_article_views_202508_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_id ATTACH PARTITION public.h_article_views_202508_id_idx;


--
-- Name: h_article_views_202508_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_user_id ATTACH PARTITION public.h_article_views_202508_user_id_idx;


--
-- Name: h_article_views_202509_article_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_article_id ATTACH PARTITION public.h_article_views_202509_article_id_idx;


--
-- Name: h_article_views_202509_article_id_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_article_views_unprocessed ATTACH PARTITION public.h_article_views_202509_article_id_idx1;


--
-- Name: h_article_views_202509_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_id ATTACH PARTITION public.h_article_views_202509_id_idx;


--
-- Name: h_article_views_202509_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_user_id ATTACH PARTITION public.h_article_views_202509_user_id_idx;


--
-- Name: h_article_views_202510_article_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_article_id ATTACH PARTITION public.h_article_views_202510_article_id_idx;


--
-- Name: h_article_views_202510_article_id_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_article_views_unprocessed ATTACH PARTITION public.h_article_views_202510_article_id_idx1;


--
-- Name: h_article_views_202510_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_id ATTACH PARTITION public.h_article_views_202510_id_idx;


--
-- Name: h_article_views_202510_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_user_id ATTACH PARTITION public.h_article_views_202510_user_id_idx;


--
-- Name: h_article_views_202511_article_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_article_id ATTACH PARTITION public.h_article_views_202511_article_id_idx;


--
-- Name: h_article_views_202511_article_id_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_article_views_unprocessed ATTACH PARTITION public.h_article_views_202511_article_id_idx1;


--
-- Name: h_article_views_202511_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_id ATTACH PARTITION public.h_article_views_202511_id_idx;


--
-- Name: h_article_views_202511_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_user_id ATTACH PARTITION public.h_article_views_202511_user_id_idx;


--
-- Name: h_article_views_202512_article_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_article_id ATTACH PARTITION public.h_article_views_202512_article_id_idx;


--
-- Name: h_article_views_202512_article_id_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_article_views_unprocessed ATTACH PARTITION public.h_article_views_202512_article_id_idx1;


--
-- Name: h_article_views_202512_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_id ATTACH PARTITION public.h_article_views_202512_id_idx;


--
-- Name: h_article_views_202512_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_user_id ATTACH PARTITION public.h_article_views_202512_user_id_idx;


--
-- Name: h_article_views_202601_article_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_article_id ATTACH PARTITION public.h_article_views_202601_article_id_idx;


--
-- Name: h_article_views_202601_article_id_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_article_views_unprocessed ATTACH PARTITION public.h_article_views_202601_article_id_idx1;


--
-- Name: h_article_views_202601_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_id ATTACH PARTITION public.h_article_views_202601_id_idx;


--
-- Name: h_article_views_202601_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_user_id ATTACH PARTITION public.h_article_views_202601_user_id_idx;


--
-- Name: h_article_views_202602_article_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_article_id ATTACH PARTITION public.h_article_views_202602_article_id_idx;


--
-- Name: h_article_views_202602_article_id_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_article_views_unprocessed ATTACH PARTITION public.h_article_views_202602_article_id_idx1;


--
-- Name: h_article_views_202602_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_id ATTACH PARTITION public.h_article_views_202602_id_idx;


--
-- Name: h_article_views_202602_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_user_id ATTACH PARTITION public.h_article_views_202602_user_id_idx;


--
-- Name: h_article_views_202603_article_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_article_id ATTACH PARTITION public.h_article_views_202603_article_id_idx;


--
-- Name: h_article_views_202603_article_id_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_article_views_unprocessed ATTACH PARTITION public.h_article_views_202603_article_id_idx1;


--
-- Name: h_article_views_202603_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_id ATTACH PARTITION public.h_article_views_202603_id_idx;


--
-- Name: h_article_views_202603_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_user_id ATTACH PARTITION public.h_article_views_202603_user_id_idx;


--
-- Name: h_article_views_202604_article_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_article_id ATTACH PARTITION public.h_article_views_202604_article_id_idx;


--
-- Name: h_article_views_202604_article_id_idx1; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_article_views_unprocessed ATTACH PARTITION public.h_article_views_202604_article_id_idx1;


--
-- Name: h_article_views_202604_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_id ATTACH PARTITION public.h_article_views_202604_id_idx;


--
-- Name: h_article_views_202604_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_article_views_on_user_id ATTACH PARTITION public.h_article_views_202604_user_id_idx;


--
-- Name: h_audit_trails_202505_changed_by_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_audit_trails_on_changed_by ATTACH PARTITION public.h_audit_trails_202505_changed_by_idx;


--
-- Name: h_audit_trails_202505_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_audit_trails_on_id ATTACH PARTITION public.h_audit_trails_202505_id_idx;


--
-- Name: h_audit_trails_202505_table_name_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_audit_trails_on_table_name ATTACH PARTITION public.h_audit_trails_202505_table_name_idx;


--
-- Name: h_error_logs_202505_error_class_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_error_class ATTACH PARTITION public.h_error_logs_202505_error_class_idx;


--
-- Name: h_error_logs_202505_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_id ATTACH PARTITION public.h_error_logs_202505_id_idx;


--
-- Name: h_error_logs_202505_request_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_id ATTACH PARTITION public.h_error_logs_202505_request_id_idx;


--
-- Name: h_error_logs_202505_request_path_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_path ATTACH PARTITION public.h_error_logs_202505_request_path_idx;


--
-- Name: h_error_logs_202505_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_user_id ATTACH PARTITION public.h_error_logs_202505_user_id_idx;


--
-- Name: h_error_logs_202506_error_class_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_error_class ATTACH PARTITION public.h_error_logs_202506_error_class_idx;


--
-- Name: h_error_logs_202506_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_id ATTACH PARTITION public.h_error_logs_202506_id_idx;


--
-- Name: h_error_logs_202506_request_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_id ATTACH PARTITION public.h_error_logs_202506_request_id_idx;


--
-- Name: h_error_logs_202506_request_path_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_path ATTACH PARTITION public.h_error_logs_202506_request_path_idx;


--
-- Name: h_error_logs_202506_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_user_id ATTACH PARTITION public.h_error_logs_202506_user_id_idx;


--
-- Name: h_error_logs_202507_error_class_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_error_class ATTACH PARTITION public.h_error_logs_202507_error_class_idx;


--
-- Name: h_error_logs_202507_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_id ATTACH PARTITION public.h_error_logs_202507_id_idx;


--
-- Name: h_error_logs_202507_request_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_id ATTACH PARTITION public.h_error_logs_202507_request_id_idx;


--
-- Name: h_error_logs_202507_request_path_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_path ATTACH PARTITION public.h_error_logs_202507_request_path_idx;


--
-- Name: h_error_logs_202507_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_user_id ATTACH PARTITION public.h_error_logs_202507_user_id_idx;


--
-- Name: h_error_logs_202508_error_class_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_error_class ATTACH PARTITION public.h_error_logs_202508_error_class_idx;


--
-- Name: h_error_logs_202508_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_id ATTACH PARTITION public.h_error_logs_202508_id_idx;


--
-- Name: h_error_logs_202508_request_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_id ATTACH PARTITION public.h_error_logs_202508_request_id_idx;


--
-- Name: h_error_logs_202508_request_path_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_path ATTACH PARTITION public.h_error_logs_202508_request_path_idx;


--
-- Name: h_error_logs_202508_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_user_id ATTACH PARTITION public.h_error_logs_202508_user_id_idx;


--
-- Name: h_error_logs_202509_error_class_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_error_class ATTACH PARTITION public.h_error_logs_202509_error_class_idx;


--
-- Name: h_error_logs_202509_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_id ATTACH PARTITION public.h_error_logs_202509_id_idx;


--
-- Name: h_error_logs_202509_request_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_id ATTACH PARTITION public.h_error_logs_202509_request_id_idx;


--
-- Name: h_error_logs_202509_request_path_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_path ATTACH PARTITION public.h_error_logs_202509_request_path_idx;


--
-- Name: h_error_logs_202509_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_user_id ATTACH PARTITION public.h_error_logs_202509_user_id_idx;


--
-- Name: h_error_logs_202510_error_class_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_error_class ATTACH PARTITION public.h_error_logs_202510_error_class_idx;


--
-- Name: h_error_logs_202510_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_id ATTACH PARTITION public.h_error_logs_202510_id_idx;


--
-- Name: h_error_logs_202510_request_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_id ATTACH PARTITION public.h_error_logs_202510_request_id_idx;


--
-- Name: h_error_logs_202510_request_path_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_path ATTACH PARTITION public.h_error_logs_202510_request_path_idx;


--
-- Name: h_error_logs_202510_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_user_id ATTACH PARTITION public.h_error_logs_202510_user_id_idx;


--
-- Name: h_error_logs_202511_error_class_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_error_class ATTACH PARTITION public.h_error_logs_202511_error_class_idx;


--
-- Name: h_error_logs_202511_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_id ATTACH PARTITION public.h_error_logs_202511_id_idx;


--
-- Name: h_error_logs_202511_request_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_id ATTACH PARTITION public.h_error_logs_202511_request_id_idx;


--
-- Name: h_error_logs_202511_request_path_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_path ATTACH PARTITION public.h_error_logs_202511_request_path_idx;


--
-- Name: h_error_logs_202511_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_user_id ATTACH PARTITION public.h_error_logs_202511_user_id_idx;


--
-- Name: h_error_logs_202512_error_class_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_error_class ATTACH PARTITION public.h_error_logs_202512_error_class_idx;


--
-- Name: h_error_logs_202512_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_id ATTACH PARTITION public.h_error_logs_202512_id_idx;


--
-- Name: h_error_logs_202512_request_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_id ATTACH PARTITION public.h_error_logs_202512_request_id_idx;


--
-- Name: h_error_logs_202512_request_path_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_path ATTACH PARTITION public.h_error_logs_202512_request_path_idx;


--
-- Name: h_error_logs_202512_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_user_id ATTACH PARTITION public.h_error_logs_202512_user_id_idx;


--
-- Name: h_error_logs_202601_error_class_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_error_class ATTACH PARTITION public.h_error_logs_202601_error_class_idx;


--
-- Name: h_error_logs_202601_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_id ATTACH PARTITION public.h_error_logs_202601_id_idx;


--
-- Name: h_error_logs_202601_request_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_id ATTACH PARTITION public.h_error_logs_202601_request_id_idx;


--
-- Name: h_error_logs_202601_request_path_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_path ATTACH PARTITION public.h_error_logs_202601_request_path_idx;


--
-- Name: h_error_logs_202601_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_user_id ATTACH PARTITION public.h_error_logs_202601_user_id_idx;


--
-- Name: h_error_logs_202602_error_class_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_error_class ATTACH PARTITION public.h_error_logs_202602_error_class_idx;


--
-- Name: h_error_logs_202602_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_id ATTACH PARTITION public.h_error_logs_202602_id_idx;


--
-- Name: h_error_logs_202602_request_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_id ATTACH PARTITION public.h_error_logs_202602_request_id_idx;


--
-- Name: h_error_logs_202602_request_path_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_path ATTACH PARTITION public.h_error_logs_202602_request_path_idx;


--
-- Name: h_error_logs_202602_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_user_id ATTACH PARTITION public.h_error_logs_202602_user_id_idx;


--
-- Name: h_error_logs_202603_error_class_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_error_class ATTACH PARTITION public.h_error_logs_202603_error_class_idx;


--
-- Name: h_error_logs_202603_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_id ATTACH PARTITION public.h_error_logs_202603_id_idx;


--
-- Name: h_error_logs_202603_request_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_id ATTACH PARTITION public.h_error_logs_202603_request_id_idx;


--
-- Name: h_error_logs_202603_request_path_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_path ATTACH PARTITION public.h_error_logs_202603_request_path_idx;


--
-- Name: h_error_logs_202603_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_user_id ATTACH PARTITION public.h_error_logs_202603_user_id_idx;


--
-- Name: h_error_logs_202604_error_class_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_error_class ATTACH PARTITION public.h_error_logs_202604_error_class_idx;


--
-- Name: h_error_logs_202604_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_id ATTACH PARTITION public.h_error_logs_202604_id_idx;


--
-- Name: h_error_logs_202604_request_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_id ATTACH PARTITION public.h_error_logs_202604_request_id_idx;


--
-- Name: h_error_logs_202604_request_path_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_request_path ATTACH PARTITION public.h_error_logs_202604_request_path_idx;


--
-- Name: h_error_logs_202604_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_error_logs_on_user_id ATTACH PARTITION public.h_error_logs_202604_user_id_idx;


--
-- Name: h_login_attempts_202505_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_login_attempts_on_id ATTACH PARTITION public.h_login_attempts_202505_id_idx;


--
-- Name: h_login_attempts_202505_ip_address_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_login_attempts_on_ip_address ATTACH PARTITION public.h_login_attempts_202505_ip_address_idx;


--
-- Name: h_login_attempts_202505_user_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_h_login_attempts_on_user_id ATTACH PARTITION public.h_login_attempts_202505_user_id_idx;


--
-- Name: h_payment_webhooks_202505_gateway_event_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_hpwebhook_gateway_event ATTACH PARTITION public.h_payment_webhooks_202505_gateway_event_id_idx;


--
-- Name: h_payment_webhooks_202506_gateway_event_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_hpwebhook_gateway_event ATTACH PARTITION public.h_payment_webhooks_202506_gateway_event_id_idx;


--
-- Name: h_payment_webhooks_202507_gateway_event_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_hpwebhook_gateway_event ATTACH PARTITION public.h_payment_webhooks_202507_gateway_event_id_idx;


--
-- Name: h_payment_webhooks_202508_gateway_event_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_hpwebhook_gateway_event ATTACH PARTITION public.h_payment_webhooks_202508_gateway_event_id_idx;


--
-- Name: h_payment_webhooks_202509_gateway_event_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_hpwebhook_gateway_event ATTACH PARTITION public.h_payment_webhooks_202509_gateway_event_id_idx;


--
-- Name: h_payment_webhooks_202510_gateway_event_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_hpwebhook_gateway_event ATTACH PARTITION public.h_payment_webhooks_202510_gateway_event_id_idx;


--
-- Name: h_payment_webhooks_202511_gateway_event_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_hpwebhook_gateway_event ATTACH PARTITION public.h_payment_webhooks_202511_gateway_event_id_idx;


--
-- Name: h_payment_webhooks_202512_gateway_event_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_hpwebhook_gateway_event ATTACH PARTITION public.h_payment_webhooks_202512_gateway_event_id_idx;


--
-- Name: h_payment_webhooks_202601_gateway_event_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_hpwebhook_gateway_event ATTACH PARTITION public.h_payment_webhooks_202601_gateway_event_id_idx;


--
-- Name: h_payment_webhooks_202602_gateway_event_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_hpwebhook_gateway_event ATTACH PARTITION public.h_payment_webhooks_202602_gateway_event_id_idx;


--
-- Name: h_payment_webhooks_202603_gateway_event_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_hpwebhook_gateway_event ATTACH PARTITION public.h_payment_webhooks_202603_gateway_event_id_idx;


--
-- Name: h_payment_webhooks_202604_gateway_event_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_hpwebhook_gateway_event ATTACH PARTITION public.h_payment_webhooks_202604_gateway_event_id_idx;


--
-- Name: h_error_logs trg_h_error_logs_compress; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_h_error_logs_compress BEFORE INSERT ON public.h_error_logs FOR EACH ROW EXECUTE FUNCTION public.tg_h_error_logs_compress();


--
-- Name: affiliate_details fk_affiliate_details_city_code; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_details
    ADD CONSTRAINT fk_affiliate_details_city_code FOREIGN KEY (city_code) REFERENCES public.m_cities(code);


--
-- Name: member_details fk_member_details_billing_city_code; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT fk_member_details_billing_city_code FOREIGN KEY (billing_city_code) REFERENCES public.m_cities(code);


--
-- Name: member_shipping_addresses fk_member_shipping_addresses_city_code; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_shipping_addresses
    ADD CONSTRAINT fk_member_shipping_addresses_city_code FOREIGN KEY (city_code) REFERENCES public.m_cities(code);


--
-- Name: affiliate_signups fk_rails_00b8de6797; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_signups
    ADD CONSTRAINT fk_rails_00b8de6797 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: stripe_payouts fk_rails_0164871fc3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_payouts
    ADD CONSTRAINT fk_rails_0164871fc3 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: quotes fk_rails_02b555fb4d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT fk_rails_02b555fb4d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: affiliate_commissions fk_rails_03512ee4df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_commissions
    ADD CONSTRAINT fk_rails_03512ee4df FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: admin_details fk_rails_0434f99b3a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_details
    ADD CONSTRAINT fk_rails_0434f99b3a FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_paint_surfaces fk_rails_04940c0fa3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_paint_surfaces
    ADD CONSTRAINT fk_rails_04940c0fa3 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_glosses fk_rails_051c4b4700; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_glosses
    ADD CONSTRAINT fk_rails_051c4b4700 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: quote_request_items fk_rails_07572f2c8b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_items
    ADD CONSTRAINT fk_rails_07572f2c8b FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: member_details fk_rails_08851c9c2d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT fk_rails_08851c9c2d FOREIGN KEY (primary_shipping_id) REFERENCES public.member_shipping_addresses(id);


--
-- Name: quote_request_items fk_rails_0ae9bad297; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_items
    ADD CONSTRAINT fk_rails_0ae9bad297 FOREIGN KEY (quote_request_id) REFERENCES public.quote_requests(id);


--
-- Name: m_corner_processes fk_rails_0c41746295; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_corner_processes
    ADD CONSTRAINT fk_rails_0c41746295 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: stripe_payments fk_rails_0c6d02e37c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_payments
    ADD CONSTRAINT fk_rails_0c6d02e37c FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_edge_processes fk_rails_0e64fecc00; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_edge_processes
    ADD CONSTRAINT fk_rails_0e64fecc00 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_paint_colors fk_rails_0e6e729dcb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_paint_colors
    ADD CONSTRAINT fk_rails_0e6e729dcb FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: member_details fk_rails_0e90e2812a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT fk_rails_0e90e2812a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: affiliate_details fk_rails_1250f45d05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_details
    ADD CONSTRAINT fk_rails_1250f45d05 FOREIGN KEY (prefecture_code) REFERENCES public.m_prefectures(code);


--
-- Name: m_paint_types fk_rails_12bace13d4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_paint_types
    ADD CONSTRAINT fk_rails_12bace13d4 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: quotes fk_rails_145bf3d23c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT fk_rails_145bf3d23c FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: quote_requests fk_rails_1466442f91; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_requests
    ADD CONSTRAINT fk_rails_1466442f91 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: quote_request_items fk_rails_14e4cbe138; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_items
    ADD CONSTRAINT fk_rails_14e4cbe138 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: vendor_details fk_rails_15b36fb913; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT fk_rails_15b36fb913 FOREIGN KEY (office_city_code) REFERENCES public.m_cities(code);


--
-- Name: payouts fk_rails_1680a8e85c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payouts
    ADD CONSTRAINT fk_rails_1680a8e85c FOREIGN KEY (transaction_ref) REFERENCES public.stripe_payouts(payout_id);


--
-- Name: quote_requests fk_rails_180f8788a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_requests
    ADD CONSTRAINT fk_rails_180f8788a0 FOREIGN KEY (vendor_id) REFERENCES public.users(id);


--
-- Name: order_reviews fk_rails_19289e95c6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT fk_rails_19289e95c6 FOREIGN KEY (vendor_id) REFERENCES public.users(id);


--
-- Name: notifications fk_rails_1b74717c67; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_rails_1b74717c67 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: quote_requests fk_rails_1b8890d53b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_requests
    ADD CONSTRAINT fk_rails_1b8890d53b FOREIGN KEY (quote_id) REFERENCES public.quotes(id);


--
-- Name: vendor_service_areas fk_rails_1d5998f1d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_service_areas
    ADD CONSTRAINT fk_rails_1d5998f1d2 FOREIGN KEY (prefecture_code) REFERENCES public.m_prefectures(code);


--
-- Name: users fk_rails_205180732b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_205180732b FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: order_reviews fk_rails_218234f6ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT fk_rails_218234f6ac FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: article_likes fk_rails_2280bc43bb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_likes
    ADD CONSTRAINT fk_rails_2280bc43bb FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: m_materials fk_rails_2486576561; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_materials
    ADD CONSTRAINT fk_rails_2486576561 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: vendor_materials fk_rails_24b9aa6af6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_materials
    ADD CONSTRAINT fk_rails_24b9aa6af6 FOREIGN KEY (material_code) REFERENCES public.m_materials(code);


--
-- Name: orders fk_rails_267c198c1b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_rails_267c198c1b FOREIGN KEY (shipping_address_id) REFERENCES public.member_shipping_addresses(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: stripe_refunds fk_rails_27113da1c6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_refunds
    ADD CONSTRAINT fk_rails_27113da1c6 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: orders fk_rails_27f9662e04; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_rails_27f9662e04 FOREIGN KEY (quote_id) REFERENCES public.quotes(id);


--
-- Name: quote_request_comments fk_rails_2965acff0f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_comments
    ADD CONSTRAINT fk_rails_2965acff0f FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: member_shipping_addresses fk_rails_2997f898f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_shipping_addresses
    ADD CONSTRAINT fk_rails_2997f898f1 FOREIGN KEY (member_id) REFERENCES public.member_details(user_id) ON DELETE CASCADE;


--
-- Name: m_paint_surfaces fk_rails_2c0d76fe0e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_paint_surfaces
    ADD CONSTRAINT fk_rails_2c0d76fe0e FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: member_shipping_addresses fk_rails_32761ffe09; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_shipping_addresses
    ADD CONSTRAINT fk_rails_32761ffe09 FOREIGN KEY (prefecture_code) REFERENCES public.m_prefectures(code);


--
-- Name: users fk_rails_355a7ffe95; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_355a7ffe95 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: articles fk_rails_35e2f292e3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT fk_rails_35e2f292e3 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_shapes fk_rails_37e866bfd4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_shapes
    ADD CONSTRAINT fk_rails_37e866bfd4 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: quotes fk_rails_386f544620; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT fk_rails_386f544620 FOREIGN KEY (shipping_address_id) REFERENCES public.member_shipping_addresses(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: orders fk_rails_38adeaa02b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_rails_38adeaa02b FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: m_glosses fk_rails_3dcf832460; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_glosses
    ADD CONSTRAINT fk_rails_3dcf832460 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: affiliate_signups fk_rails_3ef6352d1f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_signups
    ADD CONSTRAINT fk_rails_3ef6352d1f FOREIGN KEY (signup_user_id) REFERENCES public.users(id);


--
-- Name: article_likes fk_rails_3f46dcc174; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_likes
    ADD CONSTRAINT fk_rails_3f46dcc174 FOREIGN KEY (article_id) REFERENCES public.articles(id);


--
-- Name: orders fk_rails_40865df908; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_rails_40865df908 FOREIGN KEY (quote_request_id) REFERENCES public.quote_requests(id) ON DELETE SET NULL;


--
-- Name: m_cities fk_rails_42109644b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_cities
    ADD CONSTRAINT fk_rails_42109644b2 FOREIGN KEY (prefecture_code) REFERENCES public.m_prefectures(code);


--
-- Name: articles fk_rails_4297cebbfe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT fk_rails_4297cebbfe FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: m_hole_diameters fk_rails_42c61c1cc6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_hole_diameters
    ADD CONSTRAINT fk_rails_42c61c1cc6 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: m_prefectures fk_rails_4364687b87; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_prefectures
    ADD CONSTRAINT fk_rails_4364687b87 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: article_comments fk_rails_439c61b372; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_comments
    ADD CONSTRAINT fk_rails_439c61b372 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_authorities fk_rails_44f5207aff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_authorities
    ADD CONSTRAINT fk_rails_44f5207aff FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_categories fk_rails_451e72c106; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_categories
    ADD CONSTRAINT fk_rails_451e72c106 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_45307c95a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_45307c95a3 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: admin_details fk_rails_45d29e92b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_details
    ADD CONSTRAINT fk_rails_45d29e92b6 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: stripe_payments fk_rails_47bb1f7459; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_payments
    ADD CONSTRAINT fk_rails_47bb1f7459 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: m_materials fk_rails_48223032c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_materials
    ADD CONSTRAINT fk_rails_48223032c7 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: quote_request_comments fk_rails_48c0b3f433; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_comments
    ADD CONSTRAINT fk_rails_48c0b3f433 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_postal_codes fk_rails_4a069ba98b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_postal_codes
    ADD CONSTRAINT fk_rails_4a069ba98b FOREIGN KEY (city_code) REFERENCES public.m_cities(code);


--
-- Name: stripe_payments fk_rails_4b62aa0798; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_payments
    ADD CONSTRAINT fk_rails_4b62aa0798 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_shapes fk_rails_4b6bbd888d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_shapes
    ADD CONSTRAINT fk_rails_4b6bbd888d FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_shapes fk_rails_4cab80b183; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_shapes
    ADD CONSTRAINT fk_rails_4cab80b183 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: quotes fk_rails_4d07b0b28d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT fk_rails_4d07b0b28d FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: admin_details fk_rails_4fcb60b766; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_details
    ADD CONSTRAINT fk_rails_4fcb60b766 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: article_media fk_rails_5019b4f352; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_media
    ADD CONSTRAINT fk_rails_5019b4f352 FOREIGN KEY (article_id) REFERENCES public.articles(id);


--
-- Name: stripe_accounts fk_rails_5022b25805; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_accounts
    ADD CONSTRAINT fk_rails_5022b25805 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_process_types fk_rails_50d97028ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_process_types
    ADD CONSTRAINT fk_rails_50d97028ce FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_authorities fk_rails_5230eda4ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_authorities
    ADD CONSTRAINT fk_rails_5230eda4ef FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: notifications fk_rails_5449be7f30; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_rails_5449be7f30 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: member_details fk_rails_55b88e8f8b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT fk_rails_55b88e8f8b FOREIGN KEY (registered_affiliate_id) REFERENCES public.users(id);


--
-- Name: admin_details fk_rails_560f5098d3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_details
    ADD CONSTRAINT fk_rails_560f5098d3 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: stripe_accounts fk_rails_5760439bf2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_accounts
    ADD CONSTRAINT fk_rails_5760439bf2 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: m_materials fk_rails_5e5fc68929; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_materials
    ADD CONSTRAINT fk_rails_5e5fc68929 FOREIGN KEY (category_code) REFERENCES public.m_categories(code);


--
-- Name: m_edge_processes fk_rails_608bdc2fe1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_edge_processes
    ADD CONSTRAINT fk_rails_608bdc2fe1 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: articles fk_rails_60cb0a2f23; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT fk_rails_60cb0a2f23 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: m_paint_surfaces fk_rails_6273a3930b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_paint_surfaces
    ADD CONSTRAINT fk_rails_6273a3930b FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_edge_processes fk_rails_632e7fe66e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_edge_processes
    ADD CONSTRAINT fk_rails_632e7fe66e FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: member_shipping_addresses fk_rails_63f1c23650; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_shipping_addresses
    ADD CONSTRAINT fk_rails_63f1c23650 FOREIGN KEY (city_code) REFERENCES public.m_cities(code);


--
-- Name: m_categories fk_rails_63fc147c9a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_categories
    ADD CONSTRAINT fk_rails_63fc147c9a FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: member_details fk_rails_64afa3893c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT fk_rails_64afa3893c FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: user_authorities fk_rails_64f628bee7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_authorities
    ADD CONSTRAINT fk_rails_64f628bee7 FOREIGN KEY (authority_code) REFERENCES public.m_authorities(code);


--
-- Name: vendor_materials fk_rails_651d8515a7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_materials
    ADD CONSTRAINT fk_rails_651d8515a7 FOREIGN KEY (vendor_id) REFERENCES public.vendor_details(user_id) ON DELETE CASCADE;


--
-- Name: quote_items fk_rails_65a17dc088; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_items
    ADD CONSTRAINT fk_rails_65a17dc088 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: member_shipping_addresses fk_rails_66cc3b7a7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_shipping_addresses
    ADD CONSTRAINT fk_rails_66cc3b7a7e FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: article_comments fk_rails_67982717fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_comments
    ADD CONSTRAINT fk_rails_67982717fa FOREIGN KEY (article_id) REFERENCES public.articles(id);


--
-- Name: m_hole_diameters fk_rails_68c00434d4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_hole_diameters
    ADD CONSTRAINT fk_rails_68c00434d4 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: quote_items fk_rails_68df8d50c8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_items
    ADD CONSTRAINT fk_rails_68df8d50c8 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: user_authorities fk_rails_6a8b2647b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_authorities
    ADD CONSTRAINT fk_rails_6a8b2647b8 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: vendor_service_areas fk_rails_6af0406fe8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_service_areas
    ADD CONSTRAINT fk_rails_6af0406fe8 FOREIGN KEY (vendor_id) REFERENCES public.vendor_details(user_id) ON DELETE CASCADE;


--
-- Name: member_details fk_rails_6cfc776564; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT fk_rails_6cfc776564 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: vendor_details fk_rails_6d15c353fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT fk_rails_6d15c353fd FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_paint_types fk_rails_6d6d56ac9b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_paint_types
    ADD CONSTRAINT fk_rails_6d6d56ac9b FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_grain_finishes fk_rails_70079f0d12; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_grain_finishes
    ADD CONSTRAINT fk_rails_70079f0d12 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: affiliate_details fk_rails_70a6bce611; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_details
    ADD CONSTRAINT fk_rails_70a6bce611 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: affiliate_details fk_rails_711468941e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_details
    ADD CONSTRAINT fk_rails_711468941e FOREIGN KEY (stripe_account_id) REFERENCES public.stripe_accounts(stripe_account_id);


--
-- Name: affiliate_commissions fk_rails_71684630c8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_commissions
    ADD CONSTRAINT fk_rails_71684630c8 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: order_reviews fk_rails_7266ab26e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT fk_rails_7266ab26e5 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: quote_items fk_rails_737aee6ef8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_items
    ADD CONSTRAINT fk_rails_737aee6ef8 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: vendor_details fk_rails_74ee2893b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT fk_rails_74ee2893b8 FOREIGN KEY (office_prefecture_code) REFERENCES public.m_prefectures(code);


--
-- Name: stripe_accounts fk_rails_764fb7bcbe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_accounts
    ADD CONSTRAINT fk_rails_764fb7bcbe FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: m_prefectures fk_rails_79951cc512; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_prefectures
    ADD CONSTRAINT fk_rails_79951cc512 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: stripe_refunds fk_rails_7b3495b678; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_refunds
    ADD CONSTRAINT fk_rails_7b3495b678 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: affiliate_details fk_rails_7c046c89f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_details
    ADD CONSTRAINT fk_rails_7c046c89f6 FOREIGN KEY (city_code) REFERENCES public.m_cities(code);


--
-- Name: stripe_payments fk_rails_7d60b0916f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_payments
    ADD CONSTRAINT fk_rails_7d60b0916f FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: payouts fk_rails_7e89b17246; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payouts
    ADD CONSTRAINT fk_rails_7e89b17246 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: vendor_service_areas fk_rails_7fc7dfd7b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_service_areas
    ADD CONSTRAINT fk_rails_7fc7dfd7b8 FOREIGN KEY (city_code) REFERENCES public.m_cities(code);


--
-- Name: stripe_accounts fk_rails_7feb656bba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_accounts
    ADD CONSTRAINT fk_rails_7feb656bba FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: h_affiliate_clicks fk_rails_800550e991; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_affiliate_clicks
    ADD CONSTRAINT fk_rails_800550e991 FOREIGN KEY (affiliate_user_id) REFERENCES public.users(id);


--
-- Name: article_comments fk_rails_86c76f9c76; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_comments
    ADD CONSTRAINT fk_rails_86c76f9c76 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: payouts fk_rails_8ae13af0e2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payouts
    ADD CONSTRAINT fk_rails_8ae13af0e2 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: affiliate_details fk_rails_8b1030bd18; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_details
    ADD CONSTRAINT fk_rails_8b1030bd18 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_grain_finishes fk_rails_8bfc7696b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_grain_finishes
    ADD CONSTRAINT fk_rails_8bfc7696b8 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_postal_codes fk_rails_8cab43ec13; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_postal_codes
    ADD CONSTRAINT fk_rails_8cab43ec13 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: quote_items fk_rails_8d4554da01; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_items
    ADD CONSTRAINT fk_rails_8d4554da01 FOREIGN KEY (material_category_code) REFERENCES public.m_categories(code);


--
-- Name: affiliate_commissions fk_rails_8fd375453d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_commissions
    ADD CONSTRAINT fk_rails_8fd375453d FOREIGN KEY (referred_user_id) REFERENCES public.users(id);


--
-- Name: quote_request_items fk_rails_8fe04c2eb3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_items
    ADD CONSTRAINT fk_rails_8fe04c2eb3 FOREIGN KEY (quote_item_id) REFERENCES public.quote_items(id);


--
-- Name: order_reviews fk_rails_91fa08e5f2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT fk_rails_91fa08e5f2 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: affiliate_commissions fk_rails_939dc7f310; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_commissions
    ADD CONSTRAINT fk_rails_939dc7f310 FOREIGN KEY (affiliate_user_id) REFERENCES public.users(id);


--
-- Name: vendor_details fk_rails_9550a269e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT fk_rails_9550a269e6 FOREIGN KEY (stripe_account_id) REFERENCES public.stripe_accounts(stripe_account_id);


--
-- Name: m_postal_codes fk_rails_9584d0ef32; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_postal_codes
    ADD CONSTRAINT fk_rails_9584d0ef32 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: quotes fk_rails_97a1fb3b7f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT fk_rails_97a1fb3b7f FOREIGN KEY (accepted_request_id) REFERENCES public.quote_requests(id);


--
-- Name: quote_items fk_rails_97c8b4422c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_items
    ADD CONSTRAINT fk_rails_97c8b4422c FOREIGN KEY (material_code) REFERENCES public.m_materials(code);


--
-- Name: quote_request_comments fk_rails_980f101925; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_comments
    ADD CONSTRAINT fk_rails_980f101925 FOREIGN KEY (quote_request_id) REFERENCES public.quote_requests(id);


--
-- Name: stripe_payouts fk_rails_981e366b28; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_payouts
    ADD CONSTRAINT fk_rails_981e366b28 FOREIGN KEY (stripe_account_id) REFERENCES public.stripe_accounts(stripe_account_id);


--
-- Name: m_paint_colors fk_rails_98b42979dc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_paint_colors
    ADD CONSTRAINT fk_rails_98b42979dc FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_hole_diameters fk_rails_98dcfdc04c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_hole_diameters
    ADD CONSTRAINT fk_rails_98dcfdc04c FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: affiliate_commissions fk_rails_996822f75d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_commissions
    ADD CONSTRAINT fk_rails_996822f75d FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: member_shipping_addresses fk_rails_99ee2a7033; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_shipping_addresses
    ADD CONSTRAINT fk_rails_99ee2a7033 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: orders fk_rails_9a312b3a4c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_rails_9a312b3a4c FOREIGN KEY (affiliate_id) REFERENCES public.users(id);


--
-- Name: m_process_types fk_rails_9a94eea366; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_process_types
    ADD CONSTRAINT fk_rails_9a94eea366 FOREIGN KEY (category_code) REFERENCES public.m_categories(code);


--
-- Name: orders fk_rails_9ac523da23; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_rails_9ac523da23 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_process_types fk_rails_9ae1a206fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_process_types
    ADD CONSTRAINT fk_rails_9ae1a206fd FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: quotes fk_rails_9b3fa1819d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT fk_rails_9b3fa1819d FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_cities fk_rails_9bbab727a4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_cities
    ADD CONSTRAINT fk_rails_9bbab727a4 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: m_process_types fk_rails_9c515c2693; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_process_types
    ADD CONSTRAINT fk_rails_9c515c2693 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: stripe_refunds fk_rails_9e3b8e9a53; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_refunds
    ADD CONSTRAINT fk_rails_9e3b8e9a53 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: vendor_capabilities fk_rails_9f0bc3a1c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_capabilities
    ADD CONSTRAINT fk_rails_9f0bc3a1c3 FOREIGN KEY (vendor_id) REFERENCES public.vendor_details(user_id) ON DELETE CASCADE;


--
-- Name: m_paint_colors fk_rails_9f7ace30eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_paint_colors
    ADD CONSTRAINT fk_rails_9f7ace30eb FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: m_materials fk_rails_9fd91eeecc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_materials
    ADD CONSTRAINT fk_rails_9fd91eeecc FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: quote_items fk_rails_a05653c402; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_items
    ADD CONSTRAINT fk_rails_a05653c402 FOREIGN KEY (shape_code) REFERENCES public.m_shapes(code);


--
-- Name: vendor_capabilities fk_rails_a23e589077; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_capabilities
    ADD CONSTRAINT fk_rails_a23e589077 FOREIGN KEY (capability_code) REFERENCES public.m_process_types(code);


--
-- Name: member_shipping_addresses fk_rails_aad71f9b0c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_shipping_addresses
    ADD CONSTRAINT fk_rails_aad71f9b0c FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: member_details fk_rails_aeb287d4a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT fk_rails_aeb287d4a2 FOREIGN KEY (billing_city_code) REFERENCES public.m_cities(code);


--
-- Name: order_reviews fk_rails_b27d5eba1f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT fk_rails_b27d5eba1f FOREIGN KEY (reviewer_id) REFERENCES public.users(id);


--
-- Name: m_cities fk_rails_b2a090b409; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_cities
    ADD CONSTRAINT fk_rails_b2a090b409 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_glosses fk_rails_b2e63cb87f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_glosses
    ADD CONSTRAINT fk_rails_b2e63cb87f FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: quote_items fk_rails_b48260cfd5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_items
    ADD CONSTRAINT fk_rails_b48260cfd5 FOREIGN KEY (paint_type_code) REFERENCES public.m_paint_types(code);


--
-- Name: stripe_refunds fk_rails_b61ac62e9e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_refunds
    ADD CONSTRAINT fk_rails_b61ac62e9e FOREIGN KEY (payment_intent_id) REFERENCES public.stripe_payments(payment_intent_id) ON DELETE CASCADE;


--
-- Name: affiliate_details fk_rails_b810b35d18; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_details
    ADD CONSTRAINT fk_rails_b810b35d18 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: h_payout_events fk_rails_bd2df7a8c8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.h_payout_events
    ADD CONSTRAINT fk_rails_bd2df7a8c8 FOREIGN KEY (payout_id) REFERENCES public.payouts(id);


--
-- Name: quote_request_items fk_rails_bdc5d283e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_items
    ADD CONSTRAINT fk_rails_bdc5d283e6 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: m_grain_finishes fk_rails_bf35672699; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_grain_finishes
    ADD CONSTRAINT fk_rails_bf35672699 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: quote_request_comments fk_rails_c02b3b85ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_comments
    ADD CONSTRAINT fk_rails_c02b3b85ee FOREIGN KEY (parent_id) REFERENCES public.quote_request_comments(id);


--
-- Name: member_details fk_rails_c2cdeb6f7c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT fk_rails_c2cdeb6f7c FOREIGN KEY (billing_prefecture_code) REFERENCES public.m_prefectures(code);


--
-- Name: m_cities fk_rails_c47d959888; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_cities
    ADD CONSTRAINT fk_rails_c47d959888 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: payouts fk_rails_c50a09411a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payouts
    ADD CONSTRAINT fk_rails_c50a09411a FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: affiliate_signups fk_rails_c7cac3c3b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_signups
    ADD CONSTRAINT fk_rails_c7cac3c3b6 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_corner_processes fk_rails_cbf0dca52b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_corner_processes
    ADD CONSTRAINT fk_rails_cbf0dca52b FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_prefectures fk_rails_ce3acd64e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_prefectures
    ADD CONSTRAINT fk_rails_ce3acd64e5 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: affiliate_details fk_rails_ce9ab7214f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_details
    ADD CONSTRAINT fk_rails_ce9ab7214f FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: vendor_details fk_rails_d0ad37f00a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT fk_rails_d0ad37f00a FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_postal_codes fk_rails_d6f8c39731; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_postal_codes
    ADD CONSTRAINT fk_rails_d6f8c39731 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: articles fk_rails_d87756143c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT fk_rails_d87756143c FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: article_comments fk_rails_d931c2be38; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_comments
    ADD CONSTRAINT fk_rails_d931c2be38 FOREIGN KEY (parent_id) REFERENCES public.article_comments(id);


--
-- Name: quote_items fk_rails_d9bcd636be; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_items
    ADD CONSTRAINT fk_rails_d9bcd636be FOREIGN KEY (quote_id) REFERENCES public.quotes(id);


--
-- Name: affiliate_signups fk_rails_da86bb4702; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_signups
    ADD CONSTRAINT fk_rails_da86bb4702 FOREIGN KEY (affiliate_click_id) REFERENCES public.h_affiliate_clicks(id);


--
-- Name: order_reviews fk_rails_db794df21d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT fk_rails_db794df21d FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: orders fk_rails_dc1006bb54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_rails_dc1006bb54 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: stripe_payouts fk_rails_dc468b0d39; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_payouts
    ADD CONSTRAINT fk_rails_dc468b0d39 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: quote_request_comments fk_rails_dcfea1537d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_request_comments
    ADD CONSTRAINT fk_rails_dcfea1537d FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: affiliate_signups fk_rails_df4fe43808; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_signups
    ADD CONSTRAINT fk_rails_df4fe43808 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: quote_requests fk_rails_e2f2c314b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_requests
    ADD CONSTRAINT fk_rails_e2f2c314b6 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: vendor_details fk_rails_e57cb87d98; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT fk_rails_e57cb87d98 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: m_paint_types fk_rails_e8d8c7b2a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_paint_types
    ADD CONSTRAINT fk_rails_e8d8c7b2a3 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: quote_requests fk_rails_e95a37007e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quote_requests
    ADD CONSTRAINT fk_rails_e95a37007e FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: m_authorities fk_rails_e964d916b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_authorities
    ADD CONSTRAINT fk_rails_e964d916b9 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: stripe_payouts fk_rails_ec98cdcaa7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_payouts
    ADD CONSTRAINT fk_rails_ec98cdcaa7 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: vendor_details fk_rails_ecf03c70f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT fk_rails_ecf03c70f6 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: notifications fk_rails_ee2be4cca6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_rails_ee2be4cca6 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: affiliate_commissions fk_rails_ef4e150db0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_commissions
    ADD CONSTRAINT fk_rails_ef4e150db0 FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: m_corner_processes fk_rails_f029d371ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_corner_processes
    ADD CONSTRAINT fk_rails_f029d371ff FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: article_comments fk_rails_f0e007d0f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_comments
    ADD CONSTRAINT fk_rails_f0e007d0f8 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: member_details fk_rails_f1af1cd707; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT fk_rails_f1af1cd707 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: orders fk_rails_f6acf748cd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_rails_f6acf748cd FOREIGN KEY (vendor_id) REFERENCES public.users(id);


--
-- Name: orders fk_rails_f868b47f6a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_rails_f868b47f6a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: m_categories fk_rails_f95fffab61; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_categories
    ADD CONSTRAINT fk_rails_f95fffab61 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: affiliate_signups fk_rails_fd29361a59; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliate_signups
    ADD CONSTRAINT fk_rails_fd29361a59 FOREIGN KEY (affiliate_user_id) REFERENCES public.users(id);


--
-- Name: vendor_details fk_vendor_details_office_city_code; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT fk_vendor_details_office_city_code FOREIGN KEY (office_city_code) REFERENCES public.m_cities(code);


--
-- Name: vendor_service_areas fk_vendor_service_areas_city_code; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_service_areas
    ADD CONSTRAINT fk_vendor_service_areas_city_code FOREIGN KEY (city_code) REFERENCES public.m_cities(code);


--
-- Name: h_article_views h_article_views_article_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.h_article_views
    ADD CONSTRAINT h_article_views_article_id_fkey FOREIGN KEY (article_id) REFERENCES public.articles(id);


--
-- Name: h_article_views h_article_views_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.h_article_views
    ADD CONSTRAINT h_article_views_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: h_audit_trails h_audit_trails_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.h_audit_trails
    ADD CONSTRAINT h_audit_trails_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id);


--
-- Name: h_error_logs h_error_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.h_error_logs
    ADD CONSTRAINT h_error_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: h_login_attempts h_login_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.h_login_attempts
    ADD CONSTRAINT h_login_attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: h_payment_webhooks h_payment_webhooks_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.h_payment_webhooks
    ADD CONSTRAINT h_payment_webhooks_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: h_payment_webhooks h_payment_webhooks_payout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.h_payment_webhooks
    ADD CONSTRAINT h_payment_webhooks_payout_id_fkey FOREIGN KEY (payout_id) REFERENCES public.payouts(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250519011742'),
('20250517024649'),
('20250517022626'),
('20250516041816'),
('20250516041435'),
('20250516040734'),
('20250516034743'),
('20250516030806'),
('20250516020025'),
('20250514090444'),
('20250514085213'),
('20250514084407'),
('20250514080810'),
('20250514072740'),
('20250514070200'),
('20250514052343'),
('20250514050858'),
('20250514045450'),
('20250514043410'),
('20250514042946'),
('20250514042353'),
('20250514041340'),
('20250514033035'),
('20250514030627'),
('20250514030208'),
('20250514024742'),
('20250514022214'),
('20250514015335'),
('20250513061725'),
('20250513061417'),
('20250513060950'),
('20250513060650'),
('20250513060220'),
('20250513055846'),
('20250513045831'),
('20250513044308'),
('20250513041112'),
('20250513032840'),
('20250513032709'),
('20250513024933'),
('20250513023924'),
('20250512085725'),
('20250512085335'),
('20250512084948'),
('20250512082145'),
('20250512081632'),
('20250512081107'),
('20250512075710'),
('20250512040328'),
('20250512035203'),
('20250512030903'),
('20250512030428'),
('20250512025318'),
('20250512025235'),
('20250512020944'),
('20250512015122'),
('20250512012901'),
('20250512012515'),
('20250512012112'),
('20250512011943'),
('20250512010104'),
('20250512005804'),
('20250512005526'),
('20250512004856'),
('20250512002340'),
('20250512002015'),
('20250512001232'),
('20250511072257'),
('20250511064450');

