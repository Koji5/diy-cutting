class AddMinimalColumnsToPart < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      -- 1) 先にトリガを削除（依存を外す）
      DROP TRIGGER IF EXISTS trg_parts_origin_immutable ON public.parts;

      -- 2) 関数を削除
      DROP FUNCTION IF EXISTS public.forbid_origin_update();
    SQL
  end

  def down
    execute <<~SQL
      -- 関数を最小実装で復元（OLD.origin_snapshot_id がある更新を禁止）
      CREATE OR REPLACE FUNCTION public.forbid_origin_update()
      RETURNS trigger AS $$
      BEGIN
        RAISE EXCEPTION 'origin is immutable';
        RETURN OLD;
      END;
      $$ LANGUAGE plpgsql;

      -- parts 用トリガを復元（列がある場合のみ）
      DO $$
      BEGIN
        IF EXISTS (
          SELECT 1
          FROM information_schema.columns
          WHERE table_schema = 'public'
            AND table_name   = 'parts'
            AND column_name  = 'origin_snapshot_id'
        ) THEN
          CREATE TRIGGER trg_parts_origin_immutable
          BEFORE UPDATE ON public.parts
          FOR EACH ROW
          WHEN (OLD.origin_snapshot_id IS NOT NULL)
          EXECUTE FUNCTION public.forbid_origin_update();
        END IF;
      END
      $$;
    SQL
  end
end
