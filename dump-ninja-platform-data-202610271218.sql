--
-- PostgreSQL database dump
--

\restrict IGHwfKZBAHYwzYqiRYPgI0UdfmzXImpSR37ArlFIpONGLynUCqmQpIIZ9MuxGaQ

-- Dumped from database version 18.6 (fd34222)
-- Dumped by pg_dump version 18.6

-- Started on 2026-10-27 12:18:15

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
-- TOC entry 3565 (class 0 OID 0)
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
-- TOC entry 229 (class 1259 OID 139264)
-- Name: domains; Type: TABLE; Schema: public; Owner: francesco
--

CREATE TABLE public.domains (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    hostname character varying(253) NOT NULL,
    user_id uuid,
    is_default boolean DEFAULT false NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    verification_token character varying(255),
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_domains_active_verified CHECK ((((status)::text <> 'active'::text) OR (verified_at IS NOT NULL))),
    CONSTRAINT chk_domains_owner CHECK ((((is_default = true) AND (user_id IS NULL) AND ((hostname)::text = 'n2l.ink'::text)) OR ((is_default = false) AND (user_id IS NOT NULL)))),
    CONSTRAINT chk_domains_status CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'verified'::character varying, 'active'::character varying, 'disabled'::character varying])::text[])))
);


ALTER TABLE public.domains OWNER TO francesco;

--
-- TOC entry 230 (class 1259 OID 139287)
-- Name: link_sync_jobs; Type: TABLE; Schema: public; Owner: francesco
--

CREATE TABLE public.link_sync_jobs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    anonymous_key_hash character(64) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    total_links integer DEFAULT 0 NOT NULL,
    processed_links integer DEFAULT 0 NOT NULL,
    checkpoint_index integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    retryable boolean DEFAULT false NOT NULL,
    error_code character varying(100),
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_link_sync_jobs_counts CHECK (((total_links >= 0) AND (processed_links >= 0) AND (checkpoint_index >= 0) AND (attempts >= 0))),
    CONSTRAINT chk_link_sync_jobs_processed CHECK ((processed_links <= total_links)),
    CONSTRAINT chk_link_sync_jobs_status CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'in_progress'::character varying, 'completed'::character varying, 'failed'::character varying])::text[])))
);


ALTER TABLE public.link_sync_jobs OWNER TO francesco;

--
-- TOC entry 224 (class 1259 OID 123216)
-- Name: links; Type: TABLE; Schema: public; Owner: francesco
--

CREATE TABLE public.links (
    id character varying(64) NOT NULL,
    slug character varying(32) NOT NULL,
    target text NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    domain_id uuid NOT NULL,
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
    CONSTRAINT chk_subscription_status CHECK (((status)::text = ANY ((ARRAY['trialing'::character varying, 'active'::character varying, 'past_due'::character varying, 'cancelled'::character varying, 'expired'::character varying])::text[])))
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
-- TOC entry 3551 (class 0 OID 123179)
-- Dependencies: 222
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.api_keys (id, user_id, product_id, key_hash, key_prefix, name, rate_limit, created_at, last_used_at, expires_at, revoked_at) FROM stdin;
\.


--
-- TOC entry 3552 (class 0 OID 123195)
-- Dependencies: 223
-- Data for Name: auth_sessions; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.auth_sessions (id, user_id, client_id, session_hash, refresh_token_encrypted, created_at, last_used_at, expires_at, absolute_expires_at, revoked_at) FROM stdin;
\.


--
-- TOC entry 3558 (class 0 OID 139264)
-- Dependencies: 229
-- Data for Name: domains; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.domains (id, hostname, user_id, is_default, status, verification_token, verified_at, created_at, updated_at) FROM stdin;
a644769c-6081-4f75-90e3-d88729a80eec	n2l.ink	\N	t	active	\N	2026-10-27 11:17:02.673858+00	2026-10-27 11:17:02.673858+00	2026-10-27 11:17:02.673858+00
\.


--
-- TOC entry 3559 (class 0 OID 139287)
-- Dependencies: 230
-- Data for Name: link_sync_jobs; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.link_sync_jobs (id, user_id, anonymous_key_hash, status, total_links, processed_links, checkpoint_index, attempts, retryable, error_code, started_at, completed_at, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 3553 (class 0 OID 123216)
-- Dependencies: 224
-- Data for Name: links; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.links (id, slug, target, user_id, created_at, updated_at, expires_at, domain_id) FROM stdin;
\.


--
-- TOC entry 3554 (class 0 OID 123233)
-- Dependencies: 225
-- Data for Name: plans; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.plans (id, product_id, code, name, created_at) FROM stdin;
902362be-13e4-4b9b-af50-ad0710b34201	25c1d656-083b-4569-938a-faab4ab9c845	free	Free	2026-10-27 11:17:02.673858+00
1384f95d-4e88-4c0f-a12c-7d14db8b2834	25c1d656-083b-4569-938a-faab4ab9c845	pro	Pro	2026-10-27 11:17:02.673858+00
54e5108e-602d-4775-b12c-cd94efcefa64	25c1d656-083b-4569-938a-faab4ab9c845	pro_plus	Pro+	2026-10-27 11:17:02.673858+00
\.


--
-- TOC entry 3555 (class 0 OID 123249)
-- Dependencies: 226
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.products (id, code, name, created_at) FROM stdin;
25c1d656-083b-4569-938a-faab4ab9c845	ninjaurl	NinjaURL	2026-10-22 10:14:14.723525+00
\.


--
-- TOC entry 3556 (class 0 OID 123262)
-- Dependencies: 227
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.subscriptions (id, user_id, product_id, plan_id, status, current_period_start, current_period_end, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 3557 (class 0 OID 123279)
-- Dependencies: 228
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: francesco
--

COPY public.users (id, auth_provider, auth_subject, email, name, picture_url, created_at, updated_at, last_login_at) FROM stdin;
\.


--
-- TOC entry 3348 (class 2606 OID 123192)
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- TOC entry 3353 (class 2606 OID 123213)
-- Name: auth_sessions auth_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 3355 (class 2606 OID 123215)
-- Name: auth_sessions auth_sessions_session_hash_key; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_session_hash_key UNIQUE (session_hash);


--
-- TOC entry 3383 (class 2606 OID 139284)
-- Name: domains domains_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_pkey PRIMARY KEY (id);


--
-- TOC entry 3390 (class 2606 OID 139314)
-- Name: link_sync_jobs link_sync_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.link_sync_jobs
    ADD CONSTRAINT link_sync_jobs_pkey PRIMARY KEY (id);


--
-- TOC entry 3361 (class 2606 OID 123230)
-- Name: links links_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- TOC entry 3365 (class 2606 OID 123244)
-- Name: plans plans_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--
-- TOC entry 3371 (class 2606 OID 123261)
-- Name: products products_code_key; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_code_key UNIQUE (code);


--
-- TOC entry 3373 (class 2606 OID 123259)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 3376 (class 2606 OID 123278)
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- TOC entry 3351 (class 2606 OID 123194)
-- Name: api_keys uq_api_keys_hash; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT uq_api_keys_hash UNIQUE (key_hash);


--
-- TOC entry 3386 (class 2606 OID 139286)
-- Name: domains uq_domains_hostname; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT uq_domains_hostname UNIQUE (hostname);


--
-- TOC entry 3392 (class 2606 OID 139316)
-- Name: link_sync_jobs uq_link_sync_jobs_anonymous_key; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.link_sync_jobs
    ADD CONSTRAINT uq_link_sync_jobs_anonymous_key UNIQUE (anonymous_key_hash);


--
-- TOC entry 3363 (class 2606 OID 139342)
-- Name: links uq_links_domain_slug; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT uq_links_domain_slug UNIQUE (domain_id, slug);


--
-- TOC entry 3367 (class 2606 OID 123248)
-- Name: plans uq_plan_product_pair; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT uq_plan_product_pair UNIQUE (product_id, id);


--
-- TOC entry 3369 (class 2606 OID 123246)
-- Name: plans uq_product_plan_code; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT uq_product_plan_code UNIQUE (product_id, code);


--
-- TOC entry 3379 (class 2606 OID 123295)
-- Name: users uq_users_auth_subject; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uq_users_auth_subject UNIQUE (auth_subject);


--
-- TOC entry 3381 (class 2606 OID 123293)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3349 (class 1259 OID 123336)
-- Name: idx_api_keys_user_product; Type: INDEX; Schema: public; Owner: francesco
--

CREATE INDEX idx_api_keys_user_product ON public.api_keys USING btree (user_id, product_id);


--
-- TOC entry 3356 (class 1259 OID 139337)
-- Name: idx_auth_sessions_active; Type: INDEX; Schema: public; Owner: francesco
--

CREATE INDEX idx_auth_sessions_active ON public.auth_sessions USING btree (user_id, expires_at) WHERE (revoked_at IS NULL);


--
-- TOC entry 3357 (class 1259 OID 139338)
-- Name: idx_auth_sessions_user_id; Type: INDEX; Schema: public; Owner: francesco
--

CREATE INDEX idx_auth_sessions_user_id ON public.auth_sessions USING btree (user_id);


--
-- TOC entry 3384 (class 1259 OID 139328)
-- Name: idx_domains_user_status; Type: INDEX; Schema: public; Owner: francesco
--

CREATE INDEX idx_domains_user_status ON public.domains USING btree (user_id, status);


--
-- TOC entry 3388 (class 1259 OID 139330)
-- Name: idx_link_sync_jobs_user_status; Type: INDEX; Schema: public; Owner: francesco
--

CREATE INDEX idx_link_sync_jobs_user_status ON public.link_sync_jobs USING btree (user_id, status);


--
-- TOC entry 3358 (class 1259 OID 139336)
-- Name: idx_links_domain_id; Type: INDEX; Schema: public; Owner: francesco
--

CREATE INDEX idx_links_domain_id ON public.links USING btree (domain_id);


--
-- TOC entry 3359 (class 1259 OID 123339)
-- Name: idx_links_user_created_at; Type: INDEX; Schema: public; Owner: francesco
--

CREATE INDEX idx_links_user_created_at ON public.links USING btree (user_id, created_at);


--
-- TOC entry 3374 (class 1259 OID 139339)
-- Name: idx_subscriptions_user_product; Type: INDEX; Schema: public; Owner: francesco
--

CREATE INDEX idx_subscriptions_user_product ON public.subscriptions USING btree (user_id, product_id);


--
-- TOC entry 3377 (class 1259 OID 139340)
-- Name: uq_active_subscription_per_product; Type: INDEX; Schema: public; Owner: francesco
--

CREATE UNIQUE INDEX uq_active_subscription_per_product ON public.subscriptions USING btree (user_id, product_id) WHERE ((status)::text = ANY ((ARRAY['trialing'::character varying, 'active'::character varying, 'past_due'::character varying])::text[]));


--
-- TOC entry 3387 (class 1259 OID 139329)
-- Name: uq_domains_single_default; Type: INDEX; Schema: public; Owner: francesco
--

CREATE UNIQUE INDEX uq_domains_single_default ON public.domains USING btree (is_default) WHERE (is_default = true);


--
-- TOC entry 3393 (class 2606 OID 123301)
-- Name: api_keys api_keys_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- TOC entry 3394 (class 2606 OID 123296)
-- Name: api_keys api_keys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3395 (class 2606 OID 123306)
-- Name: auth_sessions auth_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3402 (class 2606 OID 139318)
-- Name: domains domains_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3399 (class 2606 OID 123331)
-- Name: subscriptions fk_subscription_plan_product; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT fk_subscription_plan_product FOREIGN KEY (product_id, plan_id) REFERENCES public.plans(id, product_id) ON DELETE RESTRICT;


--
-- TOC entry 3403 (class 2606 OID 139323)
-- Name: link_sync_jobs link_sync_jobs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.link_sync_jobs
    ADD CONSTRAINT link_sync_jobs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3396 (class 2606 OID 139331)
-- Name: links links_domain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES public.domains(id) ON DELETE RESTRICT;


--
-- TOC entry 3397 (class 2606 OID 123311)
-- Name: links links_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3398 (class 2606 OID 123316)
-- Name: plans plans_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- TOC entry 3400 (class 2606 OID 123326)
-- Name: subscriptions subscriptions_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- TOC entry 3401 (class 2606 OID 123321)
-- Name: subscriptions subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: francesco
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 2088 (class 826 OID 57348)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO neon_superuser WITH GRANT OPTION;


--
-- TOC entry 2089 (class 826 OID 57347)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON TABLES TO neon_superuser WITH GRANT OPTION;


-- Completed on 2026-10-27 12:18:17

--
-- PostgreSQL database dump complete
--

\unrestrict IGHwfKZBAHYwzYqiRYPgI0UdfmzXImpSR37ArlFIpONGLynUCqmQpIIZ9MuxGaQ

