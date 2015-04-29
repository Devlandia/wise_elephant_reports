# PART 1

## Query 1
### a
CREATE INDEX wiseleph_hattan_piwik_log_visit_idx_idvisitor ON wiseleph_hattan.piwik_log_visit(idvisitor) USING BTREE;
ALTER TABLE wiseleph_hattan.piwik_log_conversion ADD FOREIGN KEY (idvisitor) REFERENCES wiseleph_hattan.piwik_log_visit(idvisitor);

# PART 2

# Query 1a
# CREATE INDEX tusks_sm_orders ON tusks.sm_orders(created) USING BTREE;

# Query 2
### a
# CHANGE QUERY TO USE = INSTEAD LIKE
CREATE INDEX wiseleph_hattan_piwik_log_visit ON wiseleph_hattan.piwik_log_visit(visit_first_action_time) USING BTREE;

### b ~ g
# CHANGE QUERY TO USE = INSTEAD LIKE