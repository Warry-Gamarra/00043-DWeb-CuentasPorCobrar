using Data.Procedures;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class ReporteService : IReporteService
    {
        public ReporteService()
        {
        }

        public IEnumerable<PagoGeneralPorFechaDTO> ReportePagosGeneralPorFecha(DateTime fechaInicio, DateTime fechaFin)
        {
            if (DateTime.Compare(fechaInicio, fechaFin) > 0)
            {
                throw new Exception("La Fecha de Fin debe ser mayor a la Fecha de Inicio.");
            }

            var pagos = USP_S_PagosGeneralPorFecha.Execute(fechaInicio, fechaFin);

            var result = pagos.Select(p => Mapper.USP_S_PagosGeneralPorFecha_To_PagoGeneralPorFechaDTO(p));

            return result;
        }

        public IEnumerable<PagoPorFacultadYFechaDTO> ReportePagosPorFacultadYFecha(string codFac, DateTime fechaInicio, DateTime fechaFin)
        {
            if (DateTime.Compare(fechaInicio, fechaFin) > 0)
            {
                throw new Exception("La Fecha de Fin debe ser mayor a la Fecha de Inicio.");
            }

            var pagos = USP_S_PagosPorFacultadYFecha.Execute(codFac, fechaInicio, fechaFin);

            var result = pagos.Select(p => Mapper.USP_S_PagosPorFacultadYFecha_To_PagoPorFacultadYFechaDTO(p));

            return result;
        }
    }
}
