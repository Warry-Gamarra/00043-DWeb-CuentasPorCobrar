using Data.Procedures;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IReporteGeneralService
    {
        IEnumerable<ResumenAnualPagoDeObligaciones_X_DiaDTO> ResumenAnualPagoDeObligaciones_X_Dia(int anio, int? entidadFinanID, int? ctaDepositoID, int? condicionPagoID);

        IEnumerable<CantidadDePagosRegistrados_X_DiaDTO> CantidadDePagosRegistrados_X_Dia(int anio, int tipoPago, int? entidadFinanID, int? ctaDepositoID, int? condicionPagoID);
    }
}
;