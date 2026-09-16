workspace "RentiCar Platform" "Domain-Driven Software Architecture with C4 Model" {

    model {
        renter = person "Vehicle Renter" "Usuario que busca, reserva y alquila vehículos." "Customer"
        owner = person "Vehicle Owner" "Propietario que publica y renta sus vehículos particulares." "Owner"
        visitor = person "Visitor" "Persona no registrada que explora la Landing Page." "Visitor"

        openRouteService = softwareSystem "OpenRouteService API" "Servicio externo para cálculo y simulación de rutas v2/directions." "External"

        renticar = softwareSystem "RentiCar Platform" "Plataforma digital para el alquiler colaborativo P2P de vehículos." {
            landingPage = container "Landing Page" "Sitio estático informativo con llamadas a la acción." "HTML5, CSS3, JavaScript" "Web Browser"
            webApp = container "Web Application" "Aplicación web Single-Page Application (SPA) para arrendatarios y dueños." "TypeScript, Angular 20, Angular Material" "Web Browser"
            apiGateway = container "RESTful API Backend" "Servicio central de reglas de negocio y endpoints REST." "Java 17/21, Spring Boot, Spring Security" "Spring Boot" {
                // IAM Bounded Context
                authCtrl = component "AuthenticationController" "Gestiona endpoints de registro e inicio de sesión JWT." "Spring REST Controller"
                usersCtrl = component "UsersController" "Gestiona perfiles y credenciales de usuario." "Spring REST Controller"
                iamCmdSvc = component "UserCommandService" "Orquesta transacciones de registro y actualización." "Spring Application Service"
                iamQrySvc = component "UserQueryService" "Provee consultas de usuarios por ID o Email." "Spring Application Service"
                userRepo = component "UserRepository" "Interfaz JPA para persistencia en tabla users." "Spring Data JPA Repository"

                // Listings Bounded Context
                vehCtrl = component "VehiclesController" "Expone catálogo, alta de autos, carga de fotos y disponibilidad." "Spring REST Controller"
                vehCmdSvc = component "VehicleCommandService" "Reglas para crear, modificar y eliminar vehículos." "Spring Application Service"
                vehQrySvc = component "VehicleQueryService" "Consultas de flota y filtros por marca/precio." "Spring Application Service"
                vehRepo = component "VehicleRepository" "Interfaz JPA para persistencia en tabla vehicles." "Spring Data JPA Repository"
                listingsFacade = component "ListingsContextFacade" "Fachada ACL para verificar estado de vehículos." "ACL Provider"

                // Booking Bounded Context
                bookingCtrl = component "BookingsController" "Endpoints para formalización, confirmación y cancelación de reservas." "Spring REST Controller"
                bookingCmdSvc = component "BookingCommandService" "Control transaccional de reservas y cálculo de tarifas." "Spring Application Service"
                bookingQrySvc = component "BookingQueryService" "Consulta de reservas activas e historial." "Spring Application Service"
                bookingRepo = component "BookingRepository" "Interfaz JPA para persistencia en tabla bookings." "Spring Data JPA Repository"
                bookingFacade = component "BookingContextFacade" "Fachada ACL para validar reservas concluidas." "ACL Provider"

                // IoT Bounded Context
                telemCtrl = component "TelemetryController" "Ingesta y consulta de coordenadas GPS, velocidad y combustible." "Spring REST Controller"
                routeCtrl = component "RouteController" "Despacha coordenadas dinámicas de simulación de ruta." "Spring REST Controller"
                telemSimulator = component "TelemetrySimulatorService" "Simulador de movimiento telemático vehicular." "Spring Service"
                orsClient = component "OpenRouteServiceApiClient" "Cliente HTTP REST hacia OpenRouteService." "Spring RestTemplate"
                telemRepo = component "TelemetryRepository" "Interfaz JPA para registros telemáticos en tabla telemetry." "Spring Data JPA Repository"

                // Reviews Bounded Context
                reviewCtrl = component "ReviewsController" "Endpoints para emitir y consultar calificaciones de 1 a 5 estrellas." "Spring REST Controller"
                reviewCmdSvc = component "ReviewCommandService" "Valida reserva completada antes de persistir reseña." "Spring Application Service"
                reviewQrySvc = component "ReviewQueryService" "Calcula promedio ponderado de satisfacción." "Spring Application Service"
                reviewRepo = component "ReviewRepository" "Interfaz JPA para persistencia en tabla reviews." "Spring Data JPA Repository"
            }
            database = container "Database" "Base de datos relacional transaccional." "TiDB Cloud / MySQL 8.0" "Database"
        }

        // Relaciones Externas
        visitor -> landingPage "Explora información y testimonios"
        landingPage -> webApp "Redirige al flujo de registro y catálogo"
        renter -> webApp "Busca autos, reserva y monitorea con GPS [HTTPS]"
        owner -> webApp "Publica autos y gestiona solicitudes [HTTPS]"
        webApp -> apiGateway "Consume endpoints REST con JWT [JSON/HTTPS]"

        // Relaciones Internas
        authCtrl -> iamCmdSvc "Invoca comandos de registro"
        usersCtrl -> iamQrySvc "Consulta usuarios"
        iamCmdSvc -> userRepo "Persiste usuario con BCrypt"
        userRepo -> database "Lee y escribe en users [JPA/SQL]"

        vehCtrl -> vehCmdSvc "Invoca creación de auto"
        vehCmdSvc -> vehRepo "Persiste vehículo"
        vehRepo -> database "Lee y escribe en vehicles [JPA/SQL]"

        bookingCtrl -> bookingCmdSvc "Solicita reserva"
        bookingCmdSvc -> bookingRepo "Persiste reserva y bloquea fechas"
        bookingRepo -> database "Lee y escribe en bookings [JPA/SQL]"

        telemCtrl -> telemRepo "Persiste telemetría"
        routeCtrl -> telemSimulator "Inicia simulación"
        telemSimulator -> orsClient "Solicita coordenadas de ruta"
        orsClient -> openRouteService "Petición HTTP directions" [HTTPS/JSON]
        telemRepo -> database "Lee y escribe en telemetry [JPA/SQL]"

        reviewCtrl -> reviewCmdSvc "Envía reseña de 5 estrellas"
        reviewCmdSvc -> bookingFacade "Verifica reserva completada [ACL]"
        reviewCmdSvc -> reviewRepo "Persiste calificación"
        reviewRepo -> database "Lee y escribe en reviews [JPA/SQL]"
    }

    views {
        systemContext renticar "Context" "Diagrama de Contexto del Sistema RentiCar" {
            include *
            autoLayout lr
        }

        container renticar "Containers" "Diagrama de Contenedores de RentiCar" {
            include *
            autoLayout tb
        }

        component apiGateway "Components" "Diagrama de Componentes de la API Spring Boot" {
            include *
            autoLayout tb
        }

        styles {
            element "Person" {
                background #08427B
                color #ffffff
                shape Person
            }
            element "Software System" {
                background #1168BD
                color #ffffff
            }
            element "Container" {
                background #1168BD
                color #ffffff
            }
            element "Component" {
                background #438DD5
                color #ffffff
            }
            element "Database" {
                background #B91C1C
                color #ffffff
                shape Cylinder
            }
            element "External" {
                background #64748B
                color #ffffff
            }
        }
    }
}
