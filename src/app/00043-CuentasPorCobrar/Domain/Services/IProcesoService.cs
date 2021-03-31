using Domain.Helpers;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IProcesoService
    {
        List<CategoriaPago> Listar_CategoriaPago_Habilitados();

        int Obtener_Prioridad_CategoriaPago(int I_CatPagoID);

        List<CuentaDeposito> Listar_Cuenta_Deposito_Habilitadas(int I_CatPagoID);

        List<Proceso> Listar_Procesos();

        Response Grabar_Proceso(ProcesoEntity procesoEntity, SaveOption saveOption);

        Response Grabar_CtaDepoProceso(CtaDepoProcesoEntity ctaDepoProcesoEntity, SaveOption saveOption);

        Proceso Obtener_Proceso(int I_ProcesoID);

        List<CtaDepoProcesoEntity> Obtener_CtasDepoProceso(int I_ProcesoID);

        List<CtaDepoProceso> Obtener_CtasDepo_X_Proceso(int I_ProcesoID);
    }
}
