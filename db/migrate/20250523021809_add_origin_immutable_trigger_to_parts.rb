class AddOriginImmutableTriggerToParts < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      CREATE OR REPLACE FUNCTION forbid_origin_update()
      RETURNS trigger AS $$
      BEGIN
        IF NEW.origin_snapshot_id IS DISTINCT FROM OLD.origin_snapshot_id
           OR NEW.origin_owner_id IS DISTINCT FROM OLD.origin_owner_id THEN
          RAISE EXCEPTION 'origin columns are immutable';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER trg_parts_origin_immutable
      BEFORE UPDATE ON parts
      FOR EACH ROW
      WHEN (OLD.origin_snapshot_id IS NOT NULL)
      EXECUTE FUNCTION forbid_origin_update();

      CREATE TRIGGER trg_part_snapshots_origin_immutable
      BEFORE UPDATE ON part_snapshots
      FOR EACH ROW
      WHEN (OLD.origin_snapshot_id IS NOT NULL)
      EXECUTE FUNCTION forbid_origin_update();
    SQL
  end

  def down
    execute <<~SQL
      DROP TRIGGER IF EXISTS trg_parts_origin_immutable          ON parts;
      DROP TRIGGER IF EXISTS trg_part_snapshots_origin_immutable ON part_snapshots;
      DROP FUNCTION IF EXISTS forbid_origin_update();
    SQL
  end
end
