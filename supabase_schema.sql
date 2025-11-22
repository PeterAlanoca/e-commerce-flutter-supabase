-- ============================================
-- Script de creación de tablas para Supabase
-- Sistema de Inventario Offline-First
-- ============================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLA: products (Productos)
-- ============================================
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  price DECIMAL(10, 2) NOT NULL,
  cost_price DECIMAL(10, 2),
  unit TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para products
CREATE INDEX IF NOT EXISTS idx_products_code ON products(code);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_updated_at ON products(updated_at);

-- ============================================
-- TABLA: stores (Tiendas)
-- ============================================
CREATE TABLE IF NOT EXISTS stores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT UNIQUE,
  name TEXT NOT NULL,
  address TEXT,
  phone TEXT,
  email TEXT,
  manager_id BIGINT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para stores
CREATE INDEX IF NOT EXISTS idx_stores_code ON stores(code);
CREATE INDEX IF NOT EXISTS idx_stores_updated_at ON stores(updated_at);

-- ============================================
-- TABLA: warehouses (Almacenes)
-- ============================================
CREATE TABLE IF NOT EXISTS warehouses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT UNIQUE,
  name TEXT NOT NULL,
  address TEXT,
  phone TEXT,
  email TEXT,
  manager_id BIGINT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para warehouses
CREATE INDEX IF NOT EXISTS idx_warehouses_code ON warehouses(code);
CREATE INDEX IF NOT EXISTS idx_warehouses_updated_at ON warehouses(updated_at);

-- ============================================
-- TABLA: employees (Empleados)
-- ============================================
CREATE TABLE IF NOT EXISTS employees (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT UNIQUE,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  position TEXT,
  document_id TEXT,
  store_id BIGINT,
  warehouse_id BIGINT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para employees
CREATE INDEX IF NOT EXISTS idx_employees_code ON employees(code);
CREATE INDEX IF NOT EXISTS idx_employees_store_id ON employees(store_id);
CREATE INDEX IF NOT EXISTS idx_employees_warehouse_id ON employees(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_employees_updated_at ON employees(updated_at);

-- ============================================
-- TABLA: users (Usuarios del sistema)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT NOT NULL UNIQUE,
  name TEXT,
  role TEXT NOT NULL CHECK (role IN ('admin', 'storeManager', 'warehouseManager')),
  employee_id BIGINT,
  store_id BIGINT,
  warehouse_id BIGINT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para users
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_store_id ON users(store_id);
CREATE INDEX IF NOT EXISTS idx_users_warehouse_id ON users(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_users_updated_at ON users(updated_at);

-- ============================================
-- TABLA: purchases (Compras)
-- ============================================
CREATE TABLE IF NOT EXISTS purchases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  number TEXT UNIQUE,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  warehouse_id BIGINT,
  store_id BIGINT,
  employee_id BIGINT,
  total DECIMAL(10, 2) NOT NULL,
  notes TEXT,
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT check_purchase_destination CHECK (
    (store_id IS NOT NULL AND warehouse_id IS NULL) OR
    (store_id IS NULL AND warehouse_id IS NOT NULL)
  )
);

-- Índices para purchases
CREATE INDEX IF NOT EXISTS idx_purchases_number ON purchases(number);
CREATE INDEX IF NOT EXISTS idx_purchases_date ON purchases(date);
CREATE INDEX IF NOT EXISTS idx_purchases_warehouse_id ON purchases(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_purchases_store_id ON purchases(store_id);
CREATE INDEX IF NOT EXISTS idx_purchases_employee_id ON purchases(employee_id);
CREATE INDEX IF NOT EXISTS idx_purchases_updated_at ON purchases(updated_at);

-- ============================================
-- TABLA: sales (Ventas)
-- ============================================
CREATE TABLE IF NOT EXISTS sales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  number TEXT UNIQUE,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  store_id BIGINT NOT NULL,
  employee_id BIGINT,
  total DECIMAL(10, 2) NOT NULL,
  customer_name TEXT,
  notes TEXT,
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para sales
CREATE INDEX IF NOT EXISTS idx_sales_number ON sales(number);
CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(date);
CREATE INDEX IF NOT EXISTS idx_sales_store_id ON sales(store_id);
CREATE INDEX IF NOT EXISTS idx_sales_employee_id ON sales(employee_id);
CREATE INDEX IF NOT EXISTS idx_sales_updated_at ON sales(updated_at);

-- ============================================
-- TABLA: transfers (Transferencias)
-- ============================================
CREATE TABLE IF NOT EXISTS transfers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  number TEXT UNIQUE,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('storeToStore', 'storeToWarehouse', 'warehouseToStore', 'warehouseToWarehouse')),
  from_store_id BIGINT,
  from_warehouse_id BIGINT,
  to_store_id BIGINT,
  to_warehouse_id BIGINT,
  employee_id BIGINT,
  notes TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'inTransit', 'completed')),
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para transfers
CREATE INDEX IF NOT EXISTS idx_transfers_number ON transfers(number);
CREATE INDEX IF NOT EXISTS idx_transfers_date ON transfers(date);
CREATE INDEX IF NOT EXISTS idx_transfers_type ON transfers(type);
CREATE INDEX IF NOT EXISTS idx_transfers_status ON transfers(status);
CREATE INDEX IF NOT EXISTS idx_transfers_from_store_id ON transfers(from_store_id);
CREATE INDEX IF NOT EXISTS idx_transfers_from_warehouse_id ON transfers(from_warehouse_id);
CREATE INDEX IF NOT EXISTS idx_transfers_to_store_id ON transfers(to_store_id);
CREATE INDEX IF NOT EXISTS idx_transfers_to_warehouse_id ON transfers(to_warehouse_id);
CREATE INDEX IF NOT EXISTS idx_transfers_updated_at ON transfers(updated_at);

-- ============================================
-- TABLA: inventories (Inventarios)
-- ============================================
CREATE TABLE IF NOT EXISTS inventories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id BIGINT NOT NULL,
  store_id BIGINT,
  warehouse_id BIGINT,
  quantity DECIMAL(10, 2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  -- Asegurar que solo haya un inventario por producto en cada ubicación
  CONSTRAINT check_location CHECK (
    (store_id IS NOT NULL AND warehouse_id IS NULL) OR
    (store_id IS NULL AND warehouse_id IS NOT NULL) OR
    (store_id IS NULL AND warehouse_id IS NULL)
  )
);

-- Índices para inventories
CREATE INDEX IF NOT EXISTS idx_inventories_product_id ON inventories(product_id);
CREATE INDEX IF NOT EXISTS idx_inventories_store_id ON inventories(store_id);
CREATE INDEX IF NOT EXISTS idx_inventories_warehouse_id ON inventories(warehouse_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_inventories_product_location ON inventories(product_id, store_id, warehouse_id);
CREATE INDEX IF NOT EXISTS idx_inventories_updated_at ON inventories(updated_at);

-- ============================================
-- FUNCIONES: Actualización automática de updated_at
-- ============================================

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para actualizar updated_at automáticamente
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_stores_updated_at BEFORE UPDATE ON stores
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_warehouses_updated_at BEFORE UPDATE ON warehouses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON employees
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_purchases_updated_at BEFORE UPDATE ON purchases
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transfers_updated_at BEFORE UPDATE ON transfers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inventories_updated_at BEFORE UPDATE ON inventories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- POLÍTICAS RLS (Row Level Security)
-- ============================================
-- Nota: Ajusta estas políticas según tus necesidades de seguridad

-- Habilitar RLS en todas las tablas
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouses ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventories ENABLE ROW LEVEL SECURITY;

-- Políticas básicas: Permitir todo (ajusta según tus necesidades)
-- Para desarrollo, puedes permitir todo. Para producción, configura políticas más restrictivas.

CREATE POLICY "Allow all operations on products" ON products
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on stores" ON stores
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on warehouses" ON warehouses
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on employees" ON employees
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on users" ON users
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on purchases" ON purchases
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on sales" ON sales
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on transfers" ON transfers
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on inventories" ON inventories
  FOR ALL USING (true) WITH CHECK (true);

-- ============================================
-- COMENTARIOS EN TABLAS
-- ============================================
COMMENT ON TABLE products IS 'Productos del inventario';
COMMENT ON TABLE stores IS 'Tiendas de la empresa';
COMMENT ON TABLE warehouses IS 'Almacenes de la empresa';
COMMENT ON TABLE employees IS 'Empleados de la empresa';
COMMENT ON TABLE users IS 'Usuarios del sistema';
COMMENT ON TABLE purchases IS 'Compras de productos';
COMMENT ON TABLE sales IS 'Ventas de productos';
COMMENT ON TABLE transfers IS 'Transferencias entre tiendas y almacenes';
COMMENT ON TABLE inventories IS 'Inventario de productos por ubicación';



