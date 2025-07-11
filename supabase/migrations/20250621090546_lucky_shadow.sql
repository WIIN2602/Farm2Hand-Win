/*
  # Fix missing columns in Farm2Hand_product table

  1. Column Fixes
    - Add `product_category` column if it doesn't exist
    - Add `created_at` column if it doesn't exist
    - Add `updated_at` column if it doesn't exist

  2. Data Integrity
    - Ensure all existing records have proper timestamps
    - Set default category for existing records without category

  3. Indexes
    - Recreate indexes for performance
*/

-- Add product_category column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Farm2Hand_product' AND column_name = 'product_category'
  ) THEN
    ALTER TABLE public."Farm2Hand_product" ADD COLUMN product_category text;
  END IF;
END $$;

-- Add created_at column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Farm2Hand_product' AND column_name = 'created_at'
  ) THEN
    ALTER TABLE public."Farm2Hand_product" ADD COLUMN created_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Add updated_at column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Farm2Hand_product' AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE public."Farm2Hand_product" ADD COLUMN updated_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Update existing records that might have null timestamps
UPDATE public."Farm2Hand_product" 
SET created_at = now() 
WHERE created_at IS NULL;

UPDATE public."Farm2Hand_product" 
SET updated_at = now() 
WHERE updated_at IS NULL;

-- Set default category for records without category
UPDATE public."Farm2Hand_product" 
SET product_category = 'อื่นๆ' 
WHERE product_category IS NULL;

-- Create indexes for better performance (recreate if they exist)
DROP INDEX IF EXISTS idx_product_category;
DROP INDEX IF EXISTS idx_product_owner;
DROP INDEX IF EXISTS idx_product_organic;
DROP INDEX IF EXISTS idx_product_in_stock;
DROP INDEX IF EXISTS idx_product_created_at;

CREATE INDEX idx_product_category ON public."Farm2Hand_product"(product_category);
CREATE INDEX idx_product_owner ON public."Farm2Hand_product"(product_owner);
CREATE INDEX idx_product_organic ON public."Farm2Hand_product"(product_organic);
CREATE INDEX idx_product_in_stock ON public."Farm2Hand_product"(in_stock);
CREATE INDEX idx_product_created_at ON public."Farm2Hand_product"(created_at);