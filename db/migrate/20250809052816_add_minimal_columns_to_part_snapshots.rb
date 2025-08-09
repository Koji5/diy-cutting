class AddMinimalColumnsToPartSnapshots < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      DROP TRIGGER IF EXISTS trg_part_snapshots_origin_immutable
      ON public.part_snapshots;
    SQL
  end

  # 元に戻す場合（関数が残っている前提）
  def down
    execute <<~SQL
      DO $$
      BEGIN
        -- 関数が存在する場合のみトリガを再作成
        IF EXISTS (
          SELECT 1
          FROM pg_proc p
          JOIN pg_namespace n ON n.oid = p.pronamespace
          WHERE p.proname = 'forbid_origin_update'
            AND n.nspname = 'public'
        ) THEN
          CREATE TRIGGER trg_part_snapshots_origin_immutable
          BEFORE UPDATE ON public.part_snapshots
          FOR EACH ROW
          WHEN (OLD.origin_snapshot_id IS NOT NULL)
          EXECUTE FUNCTION public.forbid_origin_update();
        END IF;
      END
      $$;
    SQL
  end
end
