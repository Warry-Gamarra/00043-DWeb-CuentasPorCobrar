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
        bool ValidarCodOperacionObligacion(string C_CodOperacion, string C_CodDepositante, int I_EntidadFinanID, DateTime? D_FecPago);
        bool ValidarCodOperacionTasa(string C_CodOperacion, int I_EntidadFinanID, DateTime? D_FecPago);
        void GrabarRegistroArchivo(string fileName, string urlFile, int rowsCount, int entidadFinanID, int tipoArchivoID, int currentUserId);
        Response AnularRegistroPago(int pagoProcesId, int currentUserId, DateTime fecUpdate);
        Response GrabarNroSiafPago(int pagoProcesId, int nroSiaf, int currentUserId, DateTime fecUpdate);
        PagoEntity ObtenerDatosPago(int pagoProcesId);
        List<PagoEntity> ListarPagosRegistrados(DateTime? fecIni, DateTime? fecFin, int? dependenciaId, int? entRecaudaId);
        List<PagoEntity> ListarPagosRegistrados(DateTime? fecIni, DateTime? fecFin, TipoEstudio? tipoEstudio, int? entRecaudaId);
        List<PagoEntity> BuscarPagoRegistrado(int entRecaudaId, string codOperacion);
        IEnumerable<ArchivoImportadoDTO> ListarArchivosImportados(TipoArchivoEntFinan tipoArchivo);
        IEnumerable<PagoBancoObligacionDTO> ListarPagosBanco(int? idEntidadFinanciera, int? ctdDeposito, string codOperacion, string codDepositante, DateTime? fechaInicio, DateTime? fechaFinal,
            int? condicion);
        IEnumerable<PagoBancoObligacionDTO> ListarPagosBancoPorObligacion(int idObligacion);
        PagoBancoObligacionDTO ObtenerPagoBanco(int idPagoBanco);
        Response AsignarPagoObligacion(int obligacionID, int pagoBancoID, int UserID, string motivoCoreccion);
        Response DesenlazarPagoObligacion(int pagoBancoID, int UserID, string motivoCoreccion);
    }
}
