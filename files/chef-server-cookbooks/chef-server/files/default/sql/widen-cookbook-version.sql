-- Copyright 2013 Opscode, Inc. All Rights Reserved.
--
-- This file is provided to you under the Apache License,
-- Version 2.0 (the "License"); you may not use this file
-- except in compliance with the License.  You may obtain
-- a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
-- KIND, either express or implied.  See the License for the
-- specific language governing permissions and limitations
-- under the License.
--
-- @author Oliver Ferrigni <oliver@opscode.com>
-- @author Ho-Sheng Hsiao <hosh@opscode.com>
-- See: https://github.com/opscode/chef_db/commit/389bb2c55f46f2148cbb976dac8dfbb08a1d0d5f

START TRANSACTION;

DROP VIEW cookbook_versions_by_rank;
DROP VIEW cookbook_version_dependencies;
DROP VIEW joined_cookbook_version;

ALTER TABLE cookbook_versions
  ALTER major SET DATA TYPE bigint,
  ALTER minor SET DATA TYPE bigint,
  ALTER patch SET DATA TYPE bigint;

CREATE OR REPLACE VIEW cookbook_versions_by_rank(
        -- Cookbook Version fields
        major, -- these 3 are needed for version information (duh)
        minor,
        patch,
        version, -- concatenated string of the complete version
        serialized_object, -- needed to access recipe manifest
        -- Cookbook fields
        org_id, -- used for filtering
        name, -- both version and recipe queries require the cookbook name
        -- View-specific fields
        -- (also used for filtering)
        rank) AS
SELECT v.major,
       v.minor,
       v.patch,
       v.major || '.' || v.minor || '.' || v.patch,
       v.serialized_object,
       c.org_id,
       c.name,
       rank() OVER (PARTITION BY v.cookbook_id
                              ORDER BY v.major DESC, v.minor DESC, v.patch DESC)
FROM cookbooks AS c
JOIN cookbook_versions AS v
  ON c.id = v.cookbook_id;

CREATE OR REPLACE VIEW joined_cookbook_version(
        -- Cookbook Version fields
        major, -- these 3 are needed for version information (duh)
        minor,
        patch,
        version, -- concatenated string of the complete version
        serialized_object, -- needed to access recipe manifest
        id, -- used for retrieving environment-filtered recipes
        -- Cookbook fields
        org_id, -- used for filtering
        name) -- both version and recipe queries require the cookbook name
AS
SELECT v.major,
       v.minor,
       v.patch,
       v.major || '.' || v.minor || '.' || v.patch,
       v.serialized_object,
       v.id,
       c.org_id,
       c.name
FROM cookbooks AS c
JOIN cookbook_versions AS v
  ON c.id = v.cookbook_id;

CREATE OR REPLACE VIEW cookbook_version_dependencies(
        org_id, -- for filtering
        name, -- cookbook name
        major,
        minor,
        patch,
        dependencies) -- version dependency JSON blob; needed for depsolver
AS
SELECT c.org_id,
       c.name,
       v.major,
       v.minor,
       v.patch,
       v.meta_deps
FROM cookbooks AS c
JOIN cookbook_versions AS v
  ON c.id = v.cookbook_id;

COMMIT;
