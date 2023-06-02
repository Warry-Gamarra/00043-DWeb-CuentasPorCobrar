using Data.Views;
using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IPagoService
    {
        bool ValidarCodOperacionObligacion(string C_CodOperacion, string C_CodDepositante, int I_EntidadFinanID, DateTime? D_FecPago, int? I_ProcesoIDArchivo, DateTime? D_FecVenctoArchivo);
        bool ValidarCodOperacionTasa(string C_CodOperacion, int I_EntidadFinanID, DateTime? D_FecPago);
        void GrabarRegistroArchivo(string fileName, string urlFile, int rowsCount, int entidadFinanID, int tipoArchivoID, int currentUserId);
        Response AnularRegistroPago(int pagoProcesId, int currentUserId, DateTime fecUpdate);
        Response GrabarNroSiafPago(int pagoProcesId, int nroSiaf, int currentUserId, DateTime fecUpdate);
        PagoEntity ObtenerDatosPago(int pagpagoBancoIdoProcesId);
        List<PagoEntity> ListarPagosRegistrados(DateTime? fecIni, DateTime? fecFin, int? dependenciaId, int? entRecaudaId);
        List<PagoEntity> ListarPagosRegistrados(DateTime? fecIni, DateTime? fecFin, TipoEstudio? tipoEstudio, int? entRecaudaId, TipoPago? tipoPago);
        List<PagoEntity> BuscarPagoRegistrado(int entRecaudaId, string codOperacion);
        IEnumerable<ArchivoImportadoDTO> ListarArchivosImportados(TipoArchivoEntFinan tipoArchivo);
        IEnumerable<PagoBancoObligacionDTO> ListarPagosBanco(int? idEntidadFinanciera, int? ctdDeposito, string codOperacion, string codDepositante, DateTime? fechaInicio, DateTime? fechaFinal,
            int? condicion, string nomAlumno, string apellidoPaterno, string apellidoMaterno, string codigoInterno, TipoEstudio? tipoEstudio);
        IEnumerable<PagoBancoObligacionDTO> ListarPagosBancoPorObligacion(int idObligacion);
        PagoBancoObligacionDTO ObtenerPagoBanco(int idPagoBanco);
        Response AsignarPagoObligacion(int obligacionID, int pagoBancoID, int UserID, string motivoCoreccion);
        Response DesenlazarPagoObligacion(int pagoBancoID, int UserID, string motivoCoreccion);
        IEnumerable<PagoObligacionDetalleDTO> ObtenerPagoObligacionDetalle(int idObligacionDet);

        Response ActualizarPagoTasa(int I_PagoBancoID, string C_CodDepositante, int I_TasaUnfvId, string T_Observacion, int I_CurrentUserID);

        IEnumerable<PagoBancoObligacionDTO> ObtenerPagosPorBoucher(int idEntidadFinanciera, string codOperacion, 
            string codDepositante, DateTime fechaPago);
    }
}
