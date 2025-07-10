# 📚 Resumen Visual de Documentos

## 📄 [paper.pdf] - **MelodyUD: Arquitectura de Base de Datos Escalable**
```mermaid
graph TD
    A[Spotify-Scale] --> B[PostgreSQL+Citus]
    A --> C[Kafka]
    A --> D[ClickHouse]
    B --> E[280ms playback]
    C --> F[1.4M streams]
    D --> G[$0.037/MAU]
```
**Key Points**:  
- 🎯 **Objetivo**: Stack open-source para 600M usuarios  
- 🛠️ **Tecnologías**: PostgreSQL (sharding), Kafka, ClickHouse  
- 📊 **Resultados**: 99.95% uptime, <300ms latencia  
- 🔮 **Futuro**: Flink para recomendaciones en tiempo real  

---

## 🖥️ [slides-2.pdf] - **Presentación Técnica**
```mermaid
pie
    title Modelo de Negocio
    "Suscripciones" : 70
    "Publicidad" : 25
    "Promociones" : 5
```
**Key Points**:  
- 💼 **3 Actores**: Oyentes, Creadores, Anunciantes  
- 📌 **Requisitos**: Búsqueda <150ms, uptime 99.95%  
- 🗃️ **Arquitectura**:  
  - Microservicios + Kubernetes  
  - Polyglot (SQL/NoSQL)  
- 📉 **Trade-offs**: Consistencia vs. Escalabilidad  

---

## 📑 [Technical Report.pdf] - **Reporte Detallado**
```mermaid
journey
    title Evolución del Diseño
    section Fase 1
      CockroachDB --> PostgreSQL: 72% menos contienda
    section Fase 2
      Kafka+Debezium: CDC en <1s
    section Fase 3
      Citus: 126K ops/sec
```
**Key Points**:  
- 📚 **Metodología**: 58 historias de usuario + chaos testing  
- ⚡ **Performance**: 6.4ms avg query, 31% ↑ engagement  
- ⚠️ **Limitaciones**: Cache frío en failover  
- 🔧 **Futuro**: Geo-fencing para GDPR  

---

## 🖼️ [Scientific poster.pdf] - **Póster Científico**
```mermaid
flowchart LR
    B[Business Model] --> T[Tech Stack]
    T --> R[Resultados]
    R --> P[<300ms latency]
    R --> C[$0.037 cost]
```
**Key Points**:  
- 🎨 **Visual**: Canvas de modelo de negocio  
- 📌 **Propuesta**: Blueprint open-source portable  
- 📈 **Métricas**: 20M streams concurrentes  
- 🏆 **Conclusión**: Capas especializadas = escalabilidad  

---

## 🧩 Comparativa General
| Documento          | Enfoque                     | Tecnologías Clave         | Métrica Destacada          |
|--------------------|----------------------------|--------------------------|---------------------------|
| **Paper**         | Arquitectura DB            | PostgreSQL, Kafka        | 280ms playback            |
| **Slides**        | Modelo negocio             | Kubernetes, OpenSearch   | 99.95% uptime             |
| **Report**        | Validación técnica         | Citus, ClickHouse        | 126K ops/sec              |
| **Poster**        | Resumen visual             | -                        | <300ms latency            |
```

### 🌟 Key Takeaways:
1. **Escalabilidad**: Todos los documentos destacan sharding (Citus) + streaming (Kafka).  
2. **Coste**: $0.037 por usuario es el estándar de eficiencia.  
3. **Latencia**: Objetivo unificado <300ms para playback.  

> 💡 **Recomendación**: Usar el póster para presentaciones rápidas y el reporte técnico para profundizar en validación. 

```

Este Markdown combina:  
- **Diagramas Mermaid** para visualizar relaciones.  
- **Tablas comparativas** para síntesis.  
- **Emojis** para escaneo rápido.  
- **Destacados** en negrita/color (al renderizarse).  