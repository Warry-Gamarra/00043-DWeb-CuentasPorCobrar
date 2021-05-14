using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IReporteService
    {
        IEnumerable<PagoGeneralPorFechaDTO> ReportePagosGeneralPorFecha(DateTime fechaInicio, DateTime fechaFin);

        IEnumerable<PagoPorFacultadYFechaDTO> ReportePagosPorFacultadYFecha(string codFac, DateTime fechaInicio, DateTime fechaFin);
    }
}
