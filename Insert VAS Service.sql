-- ============================================================
-- Project:  Telecom VAS Revenue Analytics
-- File:     02_insert_vas_services.sql
-- Purpose:  Insert 12 VAS service records
-- Note:     SVC012 is inactive by design
-- ============================================================

USE telecom_data;

INSERT INTO vas_services VALUES
('SVC001', 'TunePulse Daily',     'Music',     'Daily',   20.00,  1),
('SVC002', 'BeatStream Weekly',   'Music',     'Weekly',  100.00, 1),
('SVC003', 'PlayArena Daily',     'Games',     'Daily',   30.00,  1),
('SVC004', 'GameVault Weekly',    'Games',     'Weekly',  150.00, 1),
('SVC005', 'NewsFlash Daily',     'Alerts',    'Daily',   15.00,  1),
('SVC006', 'SportsPulse Weekly',  'Alerts',    'Weekly',  80.00,  1),
('SVC007', 'LifeStyle Plus',      'Lifestyle', 'Monthly', 300.00, 1),
('SVC008', 'TrendZone Weekly',    'Lifestyle', 'Weekly',  120.00, 1),
('SVC009', 'FarmInfo Weekly',     'Info',      'Weekly',  75.00,  1),
('SVC010', 'DailyInsight',        'Info',      'Daily',   10.00,  1),
('SVC011', 'RingTone Premium',    'Music',     'Monthly', 250.00, 1),
('SVC012', 'WellnessDaily',       'Info',      'Daily',   15.00,  0);