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

SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    public_uid character varying(32) NOT NULL,
    email character varying NOT NULL,
    encrypted_password character varying NOT NULL,
    role smallint NOT NULL,
    detail_type character varying(20) NOT NULL,
    detail_id bigint NOT NULL,
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
    CONSTRAINT users_detail_type_value CHECK (((detail_type)::text = ANY ((ARRAY['MemberDetail'::character varying, 'VendorDetail'::character varying, 'AdminDetail'::character varying, 'AffiliateDetail'::character varying])::text[]))),
    CONSTRAINT users_role_detail_type_consistency CHECK ((((role = 0) AND ((detail_type)::text = 'MemberDetail'::text)) OR ((role = 1) AND ((detail_type)::text = 'VendorDetail'::text)) OR ((role = 2) AND ((detail_type)::text = 'AdminDetail'::text)) OR ((role = 3) AND ((detail_type)::text = 'AffiliateDetail'::text)))),
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
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_m_authorities_on_active_flag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_m_authorities_on_active_flag ON public.m_authorities USING btree (active_flag);


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
-- Name: index_users_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_created_by_id ON public.users USING btree (created_by_id);


--
-- Name: index_users_on_deleted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_deleted_by_id ON public.users USING btree (deleted_by_id);


--
-- Name: index_users_on_detail_type_and_detail_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_detail_type_and_detail_id ON public.users USING btree (detail_type, detail_id);


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
-- Name: users fk_rails_205180732b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_205180732b FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_355a7ffe95; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_355a7ffe95 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: m_authorities fk_rails_44f5207aff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_authorities
    ADD CONSTRAINT fk_rails_44f5207aff FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_45307c95a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_45307c95a3 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_authorities fk_rails_5230eda4ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_authorities
    ADD CONSTRAINT fk_rails_5230eda4ef FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_authorities fk_rails_e964d916b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_authorities
    ADD CONSTRAINT fk_rails_e964d916b9 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250512001232'),
('20250511072257'),
('20250511064450');

