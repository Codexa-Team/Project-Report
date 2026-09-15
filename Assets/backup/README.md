# Diagram Source Code Backups (RentiCar Platform)

Este directorio contiene el código fuente formal de los modelos arquitectónicos y diagramas de diseño del sistema **RentiCar**:

1. **`renticar-architecture.dsl`**:
   - Especificación formal en **Structurizr DSL** de la arquitectura C4 (Contexto, Contenedores y Componentes).
   - Compatible con Structurizr CLI, Structurizr Lite y https://playground.structurizr.com/.

2. **`domain-class-diagram.puml`**:
   - Modelo conceptual y físico de clases orientado a objetos en notación **UML 2.5** bajo principios de **Domain-Driven Design (DDD)**.
   - Comprende los 5 Bounded Contexts (*IAM, Listings, Booking, IoT, Reviews*).
   - Renderizable con PlantUML / Kroki.

3. **`relational-database-diagram.puml`**:
   - Diagrama físico de base de datos relacional en Tercera Forma Normal (**3NF**) con cardinalidad Crow's Foot para MySQL 8.0 y TiDB Cloud.
   - Renderizable con PlantUML / Kroki.
