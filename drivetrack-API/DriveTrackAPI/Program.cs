var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddHttpClient();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Redirecionamento HTTPS
builder.Services.AddHttpsRedirection(options =>
{
    options.HttpsPort = 443;
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Redireciona automaticamente HTTP para HTTPS
app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
