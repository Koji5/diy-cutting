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
    role smallint DEFAULT 4 NOT NULL,
    stripe_customer_id character varying,
    registered_affiliate_id bigint,
    created_by_id bigint,
    updated_by_id bigint,
    deleted_flag boolean DEFAULT false NOT NULL,
    deleted_at timestamp(6) without time zone,
    deleted_by_id bigint,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_member_role CHECK ((role = 4))
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
-- Name: member_shipping_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_shipping_addresses ALTER COLUMN id SET DEFAULT nextval('public.member_shipping_addresses_id_seq'::regclass);


--
-- Name: user_authorities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_authorities ALTER COLUMN id SET DEFAULT nextval('public.user_authorities_id_seq'::regclass);


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
-- Name: m_materials m_materials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_materials
    ADD CONSTRAINT m_materials_pkey PRIMARY KEY (code);


--
-- Name: m_process_types m_process_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_process_types
    ADD CONSTRAINT m_process_types_pkey PRIMARY KEY (code);


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
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


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
-- Name: uq_member_default_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_member_default_address ON public.member_shipping_addresses USING btree (member_id) WHERE (is_default = true);


--
-- Name: member_details fk_rails_08851c9c2d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT fk_rails_08851c9c2d FOREIGN KEY (primary_shipping_id) REFERENCES public.member_shipping_addresses(id);


--
-- Name: member_details fk_rails_0e90e2812a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT fk_rails_0e90e2812a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: vendor_details fk_rails_15b36fb913; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT fk_rails_15b36fb913 FOREIGN KEY (office_city_code) REFERENCES public.m_cities(code);


--
-- Name: users fk_rails_205180732b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_205180732b FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_materials fk_rails_2486576561; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_materials
    ADD CONSTRAINT fk_rails_2486576561 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: member_shipping_addresses fk_rails_2997f898f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_shipping_addresses
    ADD CONSTRAINT fk_rails_2997f898f1 FOREIGN KEY (member_id) REFERENCES public.member_details(user_id) ON DELETE CASCADE;


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
-- Name: m_cities fk_rails_42109644b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_cities
    ADD CONSTRAINT fk_rails_42109644b2 FOREIGN KEY (prefecture_code) REFERENCES public.m_prefectures(code);


--
-- Name: m_prefectures fk_rails_4364687b87; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_prefectures
    ADD CONSTRAINT fk_rails_4364687b87 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


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
-- Name: m_materials fk_rails_48223032c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_materials
    ADD CONSTRAINT fk_rails_48223032c7 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


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
-- Name: member_details fk_rails_55b88e8f8b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT fk_rails_55b88e8f8b FOREIGN KEY (registered_affiliate_id) REFERENCES public.users(id);


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
-- Name: member_shipping_addresses fk_rails_66cc3b7a7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_shipping_addresses
    ADD CONSTRAINT fk_rails_66cc3b7a7e FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: user_authorities fk_rails_6a8b2647b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_authorities
    ADD CONSTRAINT fk_rails_6a8b2647b8 FOREIGN KEY (user_id) REFERENCES public.users(id);


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
-- Name: stripe_accounts fk_rails_7feb656bba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_accounts
    ADD CONSTRAINT fk_rails_7feb656bba FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: vendor_details fk_rails_9550a269e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT fk_rails_9550a269e6 FOREIGN KEY (stripe_account_id) REFERENCES public.stripe_accounts(stripe_account_id);


--
-- Name: member_shipping_addresses fk_rails_99ee2a7033; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_shipping_addresses
    ADD CONSTRAINT fk_rails_99ee2a7033 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: m_process_types fk_rails_9a94eea366; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_process_types
    ADD CONSTRAINT fk_rails_9a94eea366 FOREIGN KEY (category_code) REFERENCES public.m_categories(code);


--
-- Name: m_process_types fk_rails_9ae1a206fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_process_types
    ADD CONSTRAINT fk_rails_9ae1a206fd FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


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
-- Name: m_materials fk_rails_9fd91eeecc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_materials
    ADD CONSTRAINT fk_rails_9fd91eeecc FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


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
-- Name: m_cities fk_rails_b2a090b409; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_cities
    ADD CONSTRAINT fk_rails_b2a090b409 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


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
-- Name: m_prefectures fk_rails_ce3acd64e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_prefectures
    ADD CONSTRAINT fk_rails_ce3acd64e5 FOREIGN KEY (deleted_by_id) REFERENCES public.users(id);


--
-- Name: vendor_details fk_rails_d0ad37f00a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT fk_rails_d0ad37f00a FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: vendor_details fk_rails_e57cb87d98; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT fk_rails_e57cb87d98 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: m_authorities fk_rails_e964d916b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_authorities
    ADD CONSTRAINT fk_rails_e964d916b9 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: vendor_details fk_rails_ecf03c70f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_details
    ADD CONSTRAINT fk_rails_ecf03c70f6 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: member_details fk_rails_f1af1cd707; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_details
    ADD CONSTRAINT fk_rails_f1af1cd707 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: m_categories fk_rails_f95fffab61; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.m_categories
    ADD CONSTRAINT fk_rails_f95fffab61 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
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

