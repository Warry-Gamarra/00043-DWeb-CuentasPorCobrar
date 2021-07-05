using Domain.Helpers;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Views;

namespace Domain.Services
{
    public interface IObligacionService
    {
        Response Generar_Obligaciones_Pregrado(int anio, int periodo, string codFacultad, int currentUserID);

        Response Generar_Obligaciones_Posgrado(int anio, int periodo, string codGrado, int currentUserID);

        Response Generar_ObligacionesPregrado_PorAlumno(int anio, int periodo, string codAlu, string codRc, int currentUserID);

        Response Generar_ObligacionesPosgrado_PorAlumno(int anio, int periodo, string codAlu, string codRc, int currentUserID);

        IEnumerable<ObligacionDetalleDTO> Obtener_DetallePago(int anio, int periodo, string codAlu, string codRc);

        IEnumerable<CuotaPagoDTO> Obtener_CuotasPago(int anio, int periodo, string codAlu, string codRc);

        IEnumerable<CuotaPagoDTO> Obtener_CuotasPago_X_Proceso(int anio, int periodo, TipoEstudio tipoEstudio, string codDependencia);

        ImportacionPagoResponse Grabar_Pago_Obligaciones(List<PagoObligacionEntity> dataPagoObligaciones, int currentUserID);

        IEnumerable<CtaDepoProceso> Obtener_CtaDeposito_X_Periodo(int anio, int periodo);

        ObligacionAluCabEntity Obtener_ObligacionAluCab(int obligacionCabID);
    }
}
