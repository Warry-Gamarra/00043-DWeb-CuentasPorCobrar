﻿using Data.Procedures;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class ReportePosgradoService : IReportePosgradoService
    {
        public ReportePosgradoService()
        {
        }

        public IEnumerable<PagoPosgradoPorGradodDTO> ReportePagosPorGrado(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            if (DateTime.Compare(fechaInicio, fechaFin) > 0)
            {
                throw new Exception("La Fecha de Fin debe ser mayor a la Fecha de Inicio.");
            }

            var pagos = USP_S_ReportePagoObligacionesPosgrado.PagosPorGrado(fechaInicio, fechaFin, idEntidanFinanc);

            var result = pagos.Select(p => Mapper.USP_S_ReportePagoObligacionesPosgrado_To_PagoPosgradoPorGradodDTO(p));

            return result;
        }

        public IEnumerable<PagoPosgradoPorConceptoDTO> ReportePagosPorConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            if (DateTime.Compare(fechaInicio, fechaFin) > 0)
            {
                throw new Exception("La Fecha de Fin debe ser mayor a la Fecha de Inicio.");
            }

            var pagos = USP_S_ReportePagoObligacionesPosgrado.PagosPorConcepto(fechaInicio, fechaFin, idEntidanFinanc);

            var result = pagos.Select(p => Mapper.USP_S_ReportePagoObligacionesPosgrado_To_PagoPosgradoPorConceptoDTO(p));

            return result;
        }

        public IEnumerable<ConceptoPosgradoPorGradoDTO> ReporteConceptosPorGrado(string codEsc, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            if (DateTime.Compare(fechaInicio, fechaFin) > 0)
            {
                throw new Exception("La Fecha de Fin debe ser mayor a la Fecha de Inicio.");
            }

            var pagos = USP_S_ReportePagoObligacionesPosgrado.ConceptosPorGrado(codEsc, fechaInicio, fechaFin, idEntidanFinanc);

            var result = pagos.Select(p => Mapper.USP_S_ReportePagoObligacionesPosgrado_To_ConceptoPosgradoPorGradoDTO(p));

            return result;
        }

        public IEnumerable<ResumenAnualPagoDeObligaciones_X_ClasificadorDTO> ResumenAnualPagoOblig_X_Clasificadores(int anio)
        {
            var lista = USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores.Execute(anio, false);

            var result = lista.Select(
                x => Mapper.USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores_To_ResumenAnualPagoDeObligaciones_X_ClasificadorDTO(x));

            return result;
        }

        public IEnumerable<ResumenAnualPagoDeObligaciones_X_DependenciaDTO> ResumenAnualPagoOblig_X_Dependencia(int anio)
        {
            var lista = USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia.Execute(anio, false);

            var result = lista.Select(
                x => Mapper.USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia_To_ResumenAnualPagoDeObligaciones_X_DependenciaDTO(x));

            return result;
        }
    }
}
