--
-- PostgreSQL database dump
--

\restrict kWOnOxfsOEFiTMVbO3MGTyEmp5Rnd8vfGNzRRc7nEX3XKQ0tonnfydKZNlARijV

-- Dumped from database version 18.6 (fd34222)
-- Dumped by pg_dump version 18.6

-- Started on 2026-10-27 11:54:36

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
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 3519 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 123179)
-- Name: api_keys; Type: TABLE; Schema: public; Owner: francesco
--

CREATE TABLE public.api_keys (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    product_id uuid NOT NULL,
    key_hash character(64) NOT NULL,
    key_prefix character varying(16) NOT NULL,
    name character varying(100),
    rate_limit integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone,
    expires_at timestamp with time zone,
    revoked_at timestamp with time zone
);


ALTER TABLE public.api_keys OWNER TO francesco;

--
-- TOC entry 223 (class 1259 OID 123195)
-- Name: auth_sessions; Type: TABLE; Schema: public; Owner: francesco
--

CREATE TABLE public.auth_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    client_id character varying(255) NOT NULL,
    session_hash character(64) NOT NULL,
    refresh_token_encrypted text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    absolute_expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone
);


ALTER TABLE public.auth_sessions OWNER TO francesco;

--
-- TOC entry 224 (class 1259 OID 123216)
-- Name: links; Type: TABLE; Schema: public; Owner: francesco
--

CREATE TABLE public.links (
    id character varying(64) NOT NULL,
    slug character varying(32) NOT NULL,
    target text NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    CONSTRAINT chk_links_slug_format CHECK (((slug)::text ~ '^[A-Za-z0-9_-]{3,32}$'::text))
);


ALTER TABLE public.links OWNER TO francesco;

--
-- TOC entry 225 (class 1259 OID 123233)
-- Name: plans; Type: TABLE; Schema: public; Owner: francesco
--

CREATE TABLE public.plans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.plans OWNER TO francesco;

--
-- TOC entry 226 (class 1259 OID 123249)
-- Name: products; Type: TABLE; Schema: public; Owner: francesco
--

CREATE TABLE public.products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.products OWNER TO francesco;

--
-- TOC entry 227 (class 1259 OID 123262)
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: francesco
--

CREATE TABLE public.subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    product_id uuid NOT NULL,
    plan_id uuid NOT NULL,
    status character varying(30) DEFAULT 'active'::character varying NOT NULL,
    current_period_start timestamp with time zone,
    current_period_end timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_subscription_status CHECK (((status)::text = ANY (ARRAY[('trialing'::character varying)::text, ('active'::character varying)::text, ('past_due'::character varying)::text, ('cancelled'::character varying)::text, ('expired'::character varying)::text])))
);


ALTER TABLE public.subscriptions OWNER TO francesco;

--
-- TOC entry 228 (class 1259 OID 123279)
-- Name: users; Type: TABLE; Schema: public; Owner: francesco
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    auth_provider character varying(50) NOT NULL,
    auth_subject character varying(255) NOT NULL,
    email character varying(320),
    name character varying(255),
    picture_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_login_at timestamp with time zone
);


ALTER TABLE public.users OWNER TO francesco;

--
-- TOC entry 3507 (class 0 OID 123179)
-- Dependencies: 222
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.api_keys (id, user_id, product_id, key_hash, key_prefix, name, rate_limit, created_at, last_used_at, expires_at, revoked_at) FROM stdin;
\.


--
-- TOC entry 3508 (class 0 OID 123195)
-- Dependencies: 223
-- Data for Name: auth_sessions; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.auth_sessions (id, user_id, client_id, session_hash, refresh_token_encrypted, created_at, last_used_at, expires_at, absolute_expires_at, revoked_at) FROM stdin;
\.


--
-- TOC entry 3509 (class 0 OID 123216)
-- Dependencies: 224
-- Data for Name: links; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.links (id, slug, target, user_id, created_at, updated_at, expires_at) FROM stdin;
\.


--
-- TOC entry 3510 (class 0 OID 123233)
-- Dependencies: 225
-- Data for Name: plans; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.plans (id, product_id, code, name, created_at) FROM stdin;
\.


--
-- TOC entry 3511 (class 0 OID 123249)
-- Dependencies: 226
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.products (id, code, name, created_at) FROM stdin;
25c1d656-083b-4569-938a-faab4ab9c845	ninjaurl	NinjaUrl	2026-10-22 10:14:14.723525+00
\.


--
-- TOC entry 3512 (class 0 OID 123262)
-- Dependencies: 227
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.subscriptions (id, user_id, product_id, plan_id, status, current_period_start, current_period_end, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 3513 (class 0 OID 123279)
-- Dependencies: 228
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.users (id, auth_provider, auth_subject, email, name, picture_url, created_at, updated_at, last_login_at) FROM stdin;
\.


--
-- TOC entry 3319 (class 2606 OID 123192)
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- TOC entry 3324 (class 2606 OID 123213)
-- Name: auth_sessions auth_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 3326 (class 2606 OID 123215)
-- Name: auth_sessions auth_sessions_session_hash_key; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_session_hash_key UNIQUE (session_hash);


--
-- TOC entry 3331 (class 2606 OID 123230)
-- Name: links links_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- TOC entry 3335 (class 2606 OID 123244)
-- Name: plans plans_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--
-- TOC entry 3341 (class 2606 OID 123261)
-- Name: products products_code_key; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_code_key UNIQUE (code);


--
-- TOC entry 3343 (class 2606 OID 123259)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 3346 (class 2606 OID 123278)
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- TOC entry 3322 (class 2606 OID 123194)
-- Name: api_keys uq_api_keys_hash; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT uq_api_keys_hash UNIQUE (key_hash);


--
-- TOC entry 3333 (class 2606 OID 123232)
-- Name: links uq_links_slug; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT uq_links_slug UNIQUE (slug);


--
-- TOC entry 3337 (class 2606 OID 123248)
-- Name: plans uq_plan_product_pair; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT uq_plan_product_pair UNIQUE (product_id, id);


--
-- TOC entry 3339 (class 2606 OID 123246)
-- Name: plans uq_product_plan_code; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT uq_product_plan_code UNIQUE (product_id, code);


--
-- TOC entry 3349 (class 2606 OID 123295)
-- Name: users uq_users_auth_subject; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uq_users_auth_subject UNIQUE (auth_subject);


--
-- TOC entry 3351 (class 2606 OID 123293)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3320 (class 1259 OID 123336)
-- Name: idx_api_keys_user_product; Type: INDEX; Schema: public; Owner: francesco
--

CREATE INDEX idx_api_keys_user_product ON public.api_keys USING btree (user_id, product_id);


--
-- TOC entry 3327 (class 1259 OID 123337)
-- Name: idx_auth_sessions_active; Type: INDEX; Schema: public; Owner: francesco
--

CREATE INDEX idx_auth_sessions_active ON public.auth_sessions USING btree (user_id, expires_at) WHERE (revoked_at IS NULL);


--
-- TOC entry 3328 (class 1259 OID 123338)
-- Name: idx_auth_sessions_user_id; Type: INDEX; Schema: public; Owner: francesco
--

CREATE INDEX idx_auth_sessions_user_id ON public.auth_sessions USING btree (user_id);


--
-- TOC entry 3329 (class 1259 OID 123339)
-- Name: idx_links_user_created_at; Type: INDEX; Schema: public; Owner: francesco
--

CREATE INDEX idx_links_user_created_at ON public.links USING btree (user_id, created_at);


--
-- TOC entry 3344 (class 1259 OID 123340)
-- Name: idx_subscriptions_user_product; Type: INDEX; Schema: public; Owner: francesco
--

CREATE INDEX idx_subscriptions_user_product ON public.subscriptions USING btree (user_id, product_id);


--
-- TOC entry 3347 (class 1259 OID 123341)
-- Name: uq_active_subscription_per_product; Type: INDEX; Schema: public; Owner: francesco
--

CREATE UNIQUE INDEX uq_active_subscription_per_product ON public.subscriptions USING btree (user_id, product_id) WHERE ((status)::text = ANY (ARRAY[('trialing'::character varying)::text, ('active'::character varying)::text, ('past_due'::character varying)::text]));


--
-- TOC entry 3352 (class 2606 OID 123301)
-- Name: api_keys api_keys_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- TOC entry 3353 (class 2606 OID 123296)
-- Name: api_keys api_keys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3354 (class 2606 OID 123306)
-- Name: auth_sessions auth_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3357 (class 2606 OID 123331)
-- Name: subscriptions fk_subscription_plan_product; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT fk_subscription_plan_product FOREIGN KEY (product_id, plan_id) REFERENCES public.plans(id, product_id) ON DELETE RESTRICT;


--
-- TOC entry 3355 (class 2606 OID 123311)
-- Name: links links_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3356 (class 2606 OID 123316)
-- Name: plans plans_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- TOC entry 3358 (class 2606 OID 123326)
-- Name: subscriptions subscriptions_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- TOC entry 3359 (class 2606 OID 123321)
-- Name: subscriptions subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 2080 (class 826 OID 57348)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO neon_superuser WITH GRANT OPTION;


--
-- TOC entry 2081 (class 826 OID 57347)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON TABLES TO neon_superuser WITH GRANT OPTION;


-- Completed on 2026-10-27 11:54:39

--
-- PostgreSQL database dump complete
--

\unrestrict kWOnOxfsOEFiTMVbO3MGTyEmp5Rnd8vfGNzRRc7nEX3XKQ0tonnfydKZNlARijV

